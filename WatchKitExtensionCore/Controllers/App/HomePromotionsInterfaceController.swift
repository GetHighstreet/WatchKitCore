//
//  HomePromotionsInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

/**
 * The interface controller for the home promotions view
 */
class HomePromotionsInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var table: WKInterfaceTable!
    
    var context: HomePromotionsInterfaceControllerContext!
    var tableController: TableController<HomePromotion>!
    var fetchController: FetchController<HomePromotion>!
    
    var promotionsPromise = Promise<[HomePromotion], Error>()

    
    override init() {

    }
    
    override func awakeWithContext(context: AnyObject?) {
        self.context = context as! HomePromotionsInterfaceControllerContext
        
        fetchController = FetchController(batchSize: 5)
        fetchController.dataSource = { [promotionsPromise] range in
            return promotionsPromise.future.map { promotions in
                let start = min(promotions.count, range.startIndex)
                let end = min(promotions.count, range.endIndex)
                return (promotions.count, Array(promotions[start..<end]))
            }
        }
        
        let tableConf = TableControllerConfiguration(
            fetchController: fetchController,
            table: table,
            rowAndColumnForObjectAtIndex: { i in (i, 0) },
            rowType: HomePromotionsRowController.Identifier,
            updateExecutionContext: ImmediateExecutionContext
        )
        
        tableController = TableController(configuration: tableConf, contextForObjectAtIndex: { [unowned self] (promotion, index) -> ListRowControllerContext in
            return ListRowControllerContext(shared: self.context.shared, didSelectColumn: nil)
        })
        
        // we delay the loading of the products after the first one so we don't swamp
        // the watch with new images, glitching the loading transition
        fetchController.loadNextObjects(1)
        
        if let rowController = tableController.controllerForRowAtIndex(0) as? HomePromotionsRowController {
            rowController.startRevealAnimation(self.context.shared)
            rowController.showDownArrow()
            
            // only after the reveal animation started looping, we load the other promotions
            rowController.revealFragment!.onReveal.onComplete { _ in
                fetchController.loadNextObjects(4)
            }
        } else {
            fetchController.loadNextObjects(4)
        }
        
        let request = HomePromotionsListRequest()
        promotionsPromise.completeWith(self.context.shared.session.execute(request))
    }
    
    override func didAppear() {
        self.updateUserActivity(.Home)
    }
    
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if let promotion = fetchController.objectAtIndex(rowIndex) {
            let configuration = CategoryProductsConfiguration(categoryId: promotion.categoryId)
            pushControllerWithName(
                ProductListInterfaceController.Identifier,
                context: ProductListInterfaceControllerContext(context: self.context, configuration: configuration)
            )
        }
    }
    
}

/**
* The context for the Home Promotions Interface Controller.
*/
class HomePromotionsInterfaceControllerContext: InterfaceControllerContext {
    
    let shared: SharedContextType
    
    init(context: InterfaceControllerContext) {
        shared = context.shared
    }
    
}
