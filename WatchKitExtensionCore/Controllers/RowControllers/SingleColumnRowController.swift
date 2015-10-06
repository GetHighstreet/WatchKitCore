//
//  SingleColumnRowController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 11/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

class SingleColumnRowController: NSObject, ListRowController, Revealing {
    static let Identifier = "singlecolumn"
    static let columns = 1
    
    @IBOutlet weak var productImageGroup: WKInterfaceGroup!
    @IBOutlet weak var placeholderImageGroup: WKInterfaceGroup!
    @IBOutlet weak var favoriteImage: WKInterfaceImage!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
    @IBOutlet weak var brandLabel: WKInterfaceLabel!
    @IBOutlet weak var revealGroup: WKInterfaceGroup?
    
    var productOutlineFragment: ProductOutlineFragment!
    
    func setUp(context: SharedContextType) {
        if productOutlineFragment == nil {
            productOutlineFragment = ProductOutlineFragment(
                productImageGroup: productImageGroup,
                placeholderImageGroup: placeholderImageGroup,
                priceLabel: priceLabel,
                brandLabel: brandLabel,
                favoriteIconFragment: ProductFavoriteIconFragment(
                    image: favoriteImage
                ),
                revealFragment: self.revealGroup.map { revealGroup in
                    RowRevealFragment(
                        revealGroup: revealGroup
                    )
                }
            )
            productOutlineFragment.setUp(context)
        }
    }
    
    func update(context: ListRowControllerContext, executionContext: ExecutionContext, object: Any, inColumn column: Int) {
        let product = object as! Product
        
        if productOutlineFragment == nil {
            setUp(context.shared)
        }
        
        productOutlineFragment.update(context.shared, executionContext: executionContext, data: product)
    }

    func startRevealAnimation(context: SharedContextType) {
        assert(productOutlineFragment != nil, "set-up is needed")
        
        productOutlineFragment.startRevealAnimation(context)
    }
}