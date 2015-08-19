//
//  ProductDetailsInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures
import Shared

/**
 * The interface controller for the product details screen
 */
class ProductDetailsInterfaceController: WKInterfaceController {
    
    static let Identifier = "productDetails"
    
    @IBOutlet weak var imageGroup: WKInterfaceGroup!
    @IBOutlet weak var revealGroup: WKInterfaceGroup!
    @IBOutlet weak var favoriteImage: WKInterfaceImage!

    @IBOutlet weak var infoGroup: WKInterfaceGroup!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var brandLabel: WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var favoriteButton: WKInterfaceButton!
    @IBOutlet weak var favoriteButtonGroup: WKInterfaceGroup!
    
    var context: ProductDetailsInterfaceControllerContext!
    var animateChanges = false
    
    var favoriteIconFragment: ProductFavoriteIconFragment!
    
    var favoriteButtonDisplayingAction: ProductFavoriteAction?
    
    var productDetailsAvailablePromise = Promise<ProductDetails, Error>()
    
    var changeFavoriteStateToken: InvalidationToken?
    
    var imageSetPromise: Promise<Void, Error>!
    var revealedFuture: Future<Void, Error>!
    var onReveal: Future<Void, Error> {
        if let f = revealedFuture {
            return f
        }
        
        return Future(value: ())
    }
    
    var productDetailsAvailable: Future<ProductDetails, Error> {
        if let details = productDetails {
            return Future(value: details)
        }
        
        return productDetailsAvailablePromise.future
    }
    
    var detailsChangeInvalidationToken: InvalidationToken!
    var productDetails: ProductDetails? {
        didSet {
            if let token = detailsChangeInvalidationToken {
                try! token.invalidate()
            }
            detailsChangeInvalidationToken = InvalidationToken()
            
            productDetailsDidChange(animateChanges)
            
            if let details = productDetails {
                productDetailsAvailablePromise.trySuccess(details)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        self.context = context as! ProductDetailsInterfaceControllerContext
        
        // reveal procedure
        imageSetPromise = Promise<Void, Error>()
        self.revealedImage().onComplete(ImmediateOnMainExecutionContext) { [weak self] _ in
            self?.infoGroup.setHidden(false)
        }
        
        // view set-up
        favoriteIconFragment = ProductFavoriteIconFragment(image: favoriteImage)
        priceLabel.setTextColor(self.context.shared.theme.tintColor2)
        imageGroup.setBackgroundColor(self.context.shared.theme.productBackgroundColor)
        imageGroup.setBackgroundImageNamed("product_placeholder")
        
        // settin the model if we have one
        if let product = self.context.product {
            self.productDetails = ProductDetails(product: product)
        }

        // executing the deeplink action if we have one
        if let action = self.context.action where action == HSPushActionFavorite {
            // we are loaded because of a deeplink with a favorite action
            
            productDetailsAvailable.onSuccess { [weak self] _ in
                if let controller = self {
                    controller.performProductFavoriteAction(.Add)
                }
            }
        }
        
        // performing the request for additional info
        let request = ProductDetailsRequest(productId: self.context.productId);
        self.context.shared.session.execute(request).onSuccess { [weak self] productDetails -> () in
            if let detailsInterfaceController = self {
                detailsInterfaceController.productDetails = productDetails
            }
        }
    }
    
    override func willActivate() {
        // user activity
        productDetailsAvailable.onSuccess { details in
            self.updateUserActivity(.Product(id: details.product.id))
        }
        
        animateChanges = true
    }
    
    override func didDeactivate() {
        animateChanges = false
    }
    
    func productDetailsDidChange(animated: Bool) {
        priceLabel.setText(productDetails?.product.price)
        nameLabel.setText(productDetails?.product.name)
        brandLabel.setText(productDetails?.product.secondaryAttribute)
        
        if let description = productDetails?.description {
            self.descriptionLabel.setText(description)
        } else {
            // maybe show a loader
            self.descriptionLabel.setText(nil)
        }
        
        if let image = productDetails?.product.image {
            context.shared.imageCache.ensureCacheImage(image).onSuccess { [weak self] imageRef in
                self?.imageGroup.setBackgroundImage(imageRef)
            }.onComplete { [weak self] _ in
                self?.imageSetPromise.trySuccess()
            }
        }
        
        // update the menu
        clearAllMenuItems()
        if productDetails?.product.isFavorite ?? false {
            addMenuItemWithImageNamed("menu_item_icon_unfavorite", title: "ProductDetails.menu.removeFavorite".localizedInWatchKitExtension, action: Selector("removeProductFromFavorites"))
        } else {
            addMenuItemWithImageNamed("menu_item_icon_favorite", title: "ProductDetails.menu.addFavorite".localizedInWatchKitExtension, action: Selector("addProductToFavorites"))
        }
        
        imageSetPromise.future.onComplete(ImmediateOnMainExecutionContext, token:detailsChangeInvalidationToken) { [weak self] _ in
            if let controller = self {
                controller.favoriteIconFragment.update(
                    controller.context.shared,
                    data: ProductFavoriteIconFragmentData(
                        isFavorite:controller.productDetails?.product.isFavorite ?? false,
                        animated: true
                    )
                )
            }
        }
        
        updateFavoriteButtonToShowAction(productDetails?.product.favoriteToggleAction() ?? .Add, animated: animated)
    }
    
    func addProductToFavorites() {
        performProductFavoriteAction(.Add)
    }
    
    func removeProductFromFavorites() {
        performProductFavoriteAction(.Remove)
    }
    
    func performProductFavoriteAction(action: ProductFavoriteAction) {
        updateProductDetailsSetFavorited(action == .Add)
        
        try! changeFavoriteStateToken?.invalidate()
        changeFavoriteStateToken = InvalidationToken()
        
        productDetailsAvailable.onSuccess(token: changeFavoriteStateToken!) { [weak self] details in
            if let controller = self {
                controller.context.shared.session.execute(ChangeProductFavoriteStateRequest(productId: details.product.id, action: action)).onSuccess { [weak self] favorite in
                    if let controller = self {
                        controller.updateProductDetailsSetFavorited(favorite)
                    }
                }
            }
        }
    }

    func updateProductDetailsSetFavorited(favorited: Bool) {
        productDetails?.product.isFavorite = favorited
        if let details = productDetails {
            context.productDidChange?(details.product)
        }
    }
    
    @IBAction func toggleFavoriteState() {
        if let details = productDetails {
            performProductFavoriteAction(details.product.favoriteToggleAction())
        }
    }
    
    func updateFavoriteButtonToShowAction(action: ProductFavoriteAction, animated: Bool) {
        if favoriteButtonDisplayingAction != nil && favoriteButtonDisplayingAction! == action {
            return
        }
        
        let range = rangeForAnimationToAction(action, animated: animated)
        favoriteButtonGroup.startAnimatingWithImagesInRange(range, duration: NSTimeInterval(range.length)/25.0, repeatCount: 1)
        
        favoriteButtonDisplayingAction = action
    }
    
    func rangeForAnimationToAction(action: ProductFavoriteAction, animated: Bool) -> NSRange {
        
        if (animated) {
            if action == .Add {
                return NSMakeRange(28, 13)
            } else {
                return NSMakeRange(0, 28)
            }
        } else {
            return NSMakeRange(NSMaxRange(rangeForAnimationToAction(action, animated: true))-1, 1)
        }
    }
    
    
    func revealedImage() -> Future<Void, Error> {
        revealedFuture = imageSetPromise.future.flatMap { [weak self] _ -> Future<Void, Error> in
            if let controller = self {
                controller.revealGroup.setBackgroundColor(UIColor.clearColor())
                controller.revealGroup.setBackgroundImageNamed("detail_view_image_reveal")
                let duration: NSTimeInterval = 8.0 / 25.0
                controller.revealGroup.startAnimatingWithImagesInRange(NSMakeRange(0, 8), duration: duration, repeatCount: 1)
                return Future(value: (), delay: duration*0.9)
            } else {
                return Future(error: .Unspecified)
            }
        }
        
        return revealedFuture
    }
    
}

class ProductDetailsInterfaceControllerContext: InterfaceControllerContext {
    
    let shared: SharedContextType
    let productId: Int
    let product: Product?
    let productDidChange: (Product -> ())?
    let action: String?
    
    init(context: InterfaceControllerContext, product: Product, changeHandler: (Product -> ())? = nil, action: String? = nil) {
        shared = context.shared
        productId = product.id
        self.product = product
        self.productDidChange = changeHandler
        self.action = action
    }
    
    init(context: InterfaceControllerContext, productId: Int, changeHandler: (Product -> ())? = nil, action: String? = nil) {
        shared = context.shared
        self.productId = productId
        self.product = nil
        self.productDidChange = changeHandler
        self.action = action
    }
    
    func actionFromIdentifier(identifier: String?) -> String? {
        if let action = identifier where action != "" {
            return action
        }
        return nil
    }
    
}