//
//  DualColumnRowController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 11/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit

class DualColumnRowController: NSObject, ListRowController {
    static let Identifier = "dualcolumn"
    static let columns = 2
    
    @IBOutlet var leftButton: WKInterfaceButton!
    @IBOutlet var leftButtonGroup: WKInterfaceGroup!
    @IBOutlet var rightButton: WKInterfaceButton!
    @IBOutlet var rightButtonGroup: WKInterfaceGroup!
    
    var leftColumnAction: (() -> ())? = nil
    var rightColumnAction: (() -> ())? = nil
    
    var buttons: [WKInterfaceButton] {
        return [leftButton, rightButton]
    }
    
    var groups: [WKInterfaceGroup] {
        return [leftButtonGroup, rightButtonGroup]
    }
    
    var columnActions: [(()->())?] {
        get {
            return [leftColumnAction, rightColumnAction]
        }
        set(newValue) {
            assert(newValue.count == 2)
            leftColumnAction = newValue[0]
            rightColumnAction = newValue[1]
        }
    }
    
    func setUp(context: SharedContextType) {

    }
    
    func update(context: ListRowControllerContext, object: Any, inColumn column: Int) {
        // we need to do this, unfortunately, because ListRowController can't have an associated type
        // I run into a limitation of Swift 1.2 if I try to do that
        let product = object as! Product
        let group = groups[column]
        
        if let img = product.image {
            let imageWillBeQuick = context.shared.imageCache.cachedImageName(img) != nil
            
            if !imageWillBeQuick { // image will take a while, set background & placeholder
                group.setBackgroundColor(context.shared.theme.productBackgroundColor)
                group.setBackgroundImageNamed("product_placeholder")
                group.setHidden(false)
            }
            
            context.shared.imageCache.ensureCacheImage(img).onSuccess { [weak group] name in
                group?.setBackgroundImageNamed(name)
            }.onComplete { [weak group] _ in
                if imageWillBeQuick {
                    group?.setBackgroundColor(context.shared.theme.productBackgroundColor)
                    group?.setHidden(false)
                }
            }
        } else {
            // no image
            group.setBackgroundColor(context.shared.theme.productBackgroundColor)
            group.setBackgroundImageNamed("product_placeholder")
            group.setHidden(false)
        }
        
        columnActions[column] = context.didSelectColumn
    }
    
    @IBAction func selectLeftColumn() {
        performActionForColumnAtIndex(0)
    }
    
    @IBAction func selectRightColumn() {
        performActionForColumnAtIndex(1)
    }
    
    func performActionForColumnAtIndex(index: Int) {
        if let columnAction = columnActions[index] {
            columnAction()
        }
    }
}