//
//  LaunchInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures
import Shared

/**
 * The interface controller for the launch screen
 */
class LaunchInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var favoritesButton: WKInterfaceButton!
    @IBOutlet weak var favoritesButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var favoritesButtonLabel: WKInterfaceLabel!
    @IBOutlet weak var homePromotionsButton: WKInterfaceButton!
    @IBOutlet weak var homePromotionsButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var homePromotionsButtonBackgroundGroup: WKInterfaceGroup!
    @IBOutlet weak var homePromotionsButtonLabel: WKInterfaceLabel!
    
    var context: LaunchInterfaceControllerContext!
    
    override init() {
        context = LaunchInterfaceControllerContext()
        
        context.shared.session.execute(WarmUpRequest()).onComplete { _ in
            print("Warmed up!")
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        assert(context == nil)
        
        homePromotionsButtonBackgroundGroup.setBackgroundColor(self.context.shared.theme.tintColor1)
    }
    
    override func willActivate() {
        self.updateUserActivity(.Home)
    }
    
    override func didDeactivate() {
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        switch segueIdentifier {
            case "favorites":
                return context.favoritesContext()
            case "homePromotions":
                return HomePromotionsInterfaceControllerContext(context: context)
            default:
                fatalError("Segue \(segueIdentifier) not yet supported")
        }
    }
    
    func showProductDetails(productId: Int, actionIdentifier: String?) {
        let context = ProductDetailsInterfaceControllerContext(context: self.context, productId:productId, action: actionIdentifier)
        self.pushControllerWithName("productDetails", context: context)
    }
    
    func showCategory(categoryId: Int, promotionHeaderImage: Image? = nil) {
        let configuration = CategoryProductsConfiguration(categoryId: categoryId)
        self.pushControllerWithName(
            ProductListInterfaceController.Identifier,
            context: ProductListInterfaceControllerContext(context: self.context, configuration: configuration, promotionHeaderImage: promotionHeaderImage)
        )
    }
    
}

class LaunchInterfaceControllerContext: InterfaceControllerContext {
    
    let shared: SharedContextType
    
    init() {
        shared = ExtensionDelegate.sharedDelegate().sharedContext
    }
    
    func favoritesContext() -> ProductListInterfaceControllerContext {
        return ProductListInterfaceControllerContext(context: self, configuration: FavoritesConfiguration())
    }
    
}