//
//  CategoryNotificationInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures
import SwiftyJSON

class CategoryNotificationInterfaceController: WKUserNotificationInterfaceController {
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    let shared: SharedContextType
    let productsPromise = Promise<(Int, [Product]), Error>()
    
    let fetchController: FetchController<Product>
    var tableController: TableController<Product>!
    
    override init() {
        shared = ExtensionDelegate.sharedDelegate().sharedContext
        
        fetchController = FetchController(batchSize: 5)
        
        fetchController.dataSource = { [productsPromise] range in
            assert(range.startIndex == 0) // we only support fetching the first X products
            return productsPromise.future.map { count, products in
                return (products.count, products)
            }
        }
    }
    
    func setUp() {
        let tableConf = TableControllerConfiguration(
            fetchController: fetchController,
            table: table,
            rowAndColumnForObjectAtIndex: { i in (i, 0) },
            rowType: SingleColumnRowController.Identifier
        )
        
        tableController = TableController(configuration: tableConf, contextForObjectAtIndex: { [shared] (promotion, index) -> ListRowControllerContext in
            return ListRowControllerContext(shared: shared, didSelectColumn: nil)
        })
    }
    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        setUp()
        
        if let note = PushNotification(localNotification: localNotification) {
            didReceiveCategoryNotification(note)
            completionHandler(.Custom)
        } else {
            completionHandler(.Default)
        }
    }
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        setUp()
        
        if let note = PushNotification(remoteNotification: remoteNotification) {
            didReceiveCategoryNotification(note)
            completionHandler(.Custom)
        } else {
            completionHandler(.Default)
        }
    }
    
    func didReceiveCategoryNotification(notification: PushNotification) {
        titleLabel.setText(notification.title)
        
        let request = NotificationDataRequest(
            category: notification.category,
            deeplink: notification.deeplink,
            responseDeserializer: deserializeCountAndProducts
        )
        
        let response = shared.session.execute(request, cache: notification.responseCache)
        
        productsPromise.completeWith(response)

        fetchController.loadNextBatch()
        
        if let location = BrowsingLocation.fromDeeplink(notification.deeplink) {
            self.updateUserActivity(location)
        }
    }
    
}