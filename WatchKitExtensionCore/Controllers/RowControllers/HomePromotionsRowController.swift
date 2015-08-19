//
//  HomePromotionsRowController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 11/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

class HomePromotionsRowController: NSObject, ListRowController, Revealing {
    static let Identifier = "homePromotion"
    static let columns = 1
    
    @IBOutlet weak var placeholderGroup: WKInterfaceGroup!
    @IBOutlet weak var imageGroup: WKInterfaceGroup!
    @IBOutlet weak var revealGroup: WKInterfaceGroup!
    @IBOutlet weak var downArrowImage: WKInterfaceImage!
    
    var revealFragment: RowRevealFragment?
    
    func setUp(context: SharedContextType) {
        placeholderGroup.setBackgroundColor(context.theme.productBackgroundColor)
        placeholderGroup.setBackgroundImageNamed("product_placeholder")
    }
    
    func update(context: ListRowControllerContext, object: Any, inColumn column: Int) {
        let promotion = object as! HomePromotion
        
        if let image = promotion.image {
            revealDidSetImage(image).flatMap { _ in
                context.shared.imageCache.ensureCacheImage(image)
            }.onSuccess { [weak self] imageName in
                self?.imageGroup.setBackgroundImageNamed(imageName)
            }.onComplete { [weak self] _ in
                self?.revealFragment?.didFinishLoading()
            }
        } else {
            revealFragment?.didFinishLoading()
        }
    }
    
    func startRevealAnimation(context: SharedContextType) {
        if revealFragment == nil {
            revealFragment = RowRevealFragment(revealGroup: revealGroup)
        }
        
        revealFragment?.startRevealAnimation(context)
    }
    
    func showDownArrow() {
        revealFragment?.onReveal.onComplete(ImmediateOnMainExecutionContext) { [weak self]_ in
            self?.downArrowImage.setHidden(false)
        }
    }
    
    func revealDidSetImage(image: Image) -> Future<Void, Error> {
        if let f = revealFragment {
            return f.willSetImage(image)
        }
        return Future(value: ())
    }
    
}