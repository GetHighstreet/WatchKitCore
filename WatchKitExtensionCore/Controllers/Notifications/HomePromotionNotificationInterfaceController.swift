//
//  HomePromotionNotificationInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import SwiftyJSON
import BrightFutures

class HomePromotionNotificationInterfaceController: WKUserNotificationInterfaceController {
    
    @IBOutlet weak var headerImageContainerGroup: WKInterfaceGroup!
    @IBOutlet weak var headerImage: WKInterfaceGroup!
    @IBOutlet weak var headerPlaceholder: WKInterfaceGroup!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!


    let shared: SharedContextType
    let productsPromise = Promise<(Int, [Product]), Error>()
    
    let fetchController: FetchController<Product>
    var tableController: TableController<Product>!
    
    override init() {
        shared = ExtensionDelegate.sharedDelegate().sharedContext
        
        fetchController = FetchController(batchSize: 3)
        
        fetchController.dataSource = { [productsPromise] range in
            assert(range.startIndex == 0) // we only support fetching the first X products
            return productsPromise.future.map { count, products in
                return (products.count, products)
            }
        }
    }
    
    
    func setUp() {
        headerPlaceholder.setBackgroundImageNamed("product_placeholder")
        headerImageContainerGroup.setBackgroundColor(shared.theme.productBackgroundColor)
        
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
        
        if let notification = PushNotification(localNotification: localNotification) {
            didReceiveHomePromotionNotification(notification)
            Queue.main.after(NotificationCompletionHandlerDelay) {
                completionHandler(.Custom)
            }
        } else {
            completionHandler(.Default)
        }
    }
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        setUp()
        
        if let notification = PushNotification(remoteNotification: remoteNotification) {
            didReceiveHomePromotionNotification(notification)
            Queue.main.after(NotificationCompletionHandlerDelay) {
                completionHandler(.Custom)
            }
        } else {
            completionHandler(.Default)
        }
    }
    
    func didReceiveHomePromotionNotification(notification: PushNotification) {
        titleLabel.setText(notification.title)
        
  
        let request = NotificationDataRequest(
            category: notification.category,
            deeplink: notification.deeplink,
            responseDeserializer: deserializeHomePromotionWithData
        )
        
        let response = shared.session.execute(request, cache: notification.responseCache)
        
        
        let productsFuture = response.map { (_, productsAndCount) in
            return productsAndCount
        }
        
        //show products
        productsPromise.completeWith(productsFuture)
        
        
        //set header image
        response.onSuccess { [weak self] (promotion,_) in
            if let image = promotion.image {
                self?.shared.imageCache.ensureCacheImage(image).onSuccess {
                    self?.headerImage.setBackgroundImage($0)
                    self?.headerImage.setHidden(false)
                    self?.headerPlaceholder.setHidden(true)
                }
            }
            
        }
    
        fetchController.loadNextBatch()
        
        if let location = BrowsingLocation.fromDeeplink(notification.deeplink) {
            self.updateUserActivity(location)
        }
    }
}