//
//  ProductOutlineFragment.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

/**
 * Fragment for the product outline UI element.
 */
class ProductOutlineFragment: InterfaceFragment, Revealing {
    
    let productImageGroup: WKInterfaceGroup
    let placeholderImageGroup: WKInterfaceGroup
    let priceLabel: WKInterfaceLabel
    let brandLabel: WKInterfaceLabel
    var favoriteIconFragment: ProductFavoriteIconFragment
    var revealFragment: RowRevealFragment?
    
    init(productImageGroup: WKInterfaceGroup, placeholderImageGroup: WKInterfaceGroup, priceLabel: WKInterfaceLabel, brandLabel: WKInterfaceLabel, favoriteIconFragment: ProductFavoriteIconFragment, revealFragment: RowRevealFragment?) {
        self.productImageGroup = productImageGroup
        self.placeholderImageGroup = placeholderImageGroup
        self.priceLabel = priceLabel
        self.brandLabel = brandLabel
        self.favoriteIconFragment = favoriteIconFragment
        self.revealFragment = revealFragment
    }
    
    func setUp(context: SharedContextType) {
        favoriteIconFragment.setUp(context)
        placeholderImageGroup.setBackgroundImageNamed("product_placeholder")
        
        productImageGroup.setBackgroundColor(context.theme.productBackgroundColor)
        
        priceLabel.setHidden(true)
        brandLabel.setHidden(true)
        
        priceLabel.setTextColor(context.theme.tintColor2)
    }
    
    func update(context: SharedContextType, executionContext: ExecutionContext, data: Product) {
        
        if let image = data.image {
            revealDidSetImage(image).flatMap { _ in
                context.imageCache.ensureCacheImage(image)
            }.onSuccess(executionContext) { image in
                self.placeholderImageGroup.setBackgroundImageNamed(nil)
                self.productImageGroup.setBackgroundImage(image)
            }.onComplete { _ in
                self.revealFragment?.didFinishLoading()
            }
        } else {
            self.revealFragment?.didFinishLoading()
        }
        
        if let revealFragment = revealFragment {
            revealFragment.onReveal.onComplete(executionContext) { _ in
                self.updateTextWithProduct(data, context: context, executionContext: executionContext)
            }
        } else {
            updateTextWithProduct(data, context: context, executionContext: executionContext)
        }
    }
    
    func updateTextWithProduct(product: Product, context: SharedContextType, executionContext: ExecutionContext) {
        priceLabel.setText(product.price)
        //brandLabel.setText(product.secondaryAttribute)
        
        priceLabel.setHidden(false)
        //brandLabel.setHidden(false)
        
        favoriteIconFragment.update(context, executionContext: executionContext, data: ProductFavoriteIconFragmentData(isFavorite: product.isFavorite, animated: false))
    }
    
    func startRevealAnimation(context: SharedContextType) {
        revealFragment?.startRevealAnimation(context)
    }
    
    func revealDidSetImage(image: Image) -> Future<Void, Error> {
        if let f = revealFragment {
            return f.willSetImage(image)
        }
        return Future(value: ())
    }
}