//
//  ProductNotificationInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import SwiftyJSON
import BrightFutures

class ProductNotificationInterfaceController: WKUserNotificationInterfaceController {
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    @IBOutlet weak var productImageGroup: WKInterfaceGroup!
    @IBOutlet weak var placeholderImageGroup: WKInterfaceGroup!
    @IBOutlet weak var favoriteImage: WKInterfaceImage!
    @IBOutlet weak var priceLabel: WKInterfaceLabel!
    @IBOutlet weak var brandLabel: WKInterfaceLabel!
    
    let shared: SharedContextType
    var productOutlineFragment: ProductOutlineFragment!
    
    override init() {
        shared = ExtensionDelegate.sharedDelegate().sharedContext
    }
    
    /**
     * Since awakeWithContext: is not called, we have to trigger our
     * own set-up mechanism
     */
    func setUp() {
        productOutlineFragment = ProductOutlineFragment(
            productImageGroup: productImageGroup,
            placeholderImageGroup: placeholderImageGroup,
            priceLabel: priceLabel,
            brandLabel: brandLabel,
            favoriteIconFragment: ProductFavoriteIconFragment(
                image: favoriteImage
            ),
            revealFragment: nil
        )
        productOutlineFragment.setUp(shared)
    }
    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        setUp()

        if let note = PushNotification(localNotification: localNotification) {
            didReceiveProductNotification(note)
            Queue.main.after(NotificationCompletionHandlerDelay) {
                completionHandler(.Custom)
            }
        } else {
            completionHandler(.Default)
        }
    }
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        setUp()
        
        if let note = PushNotification(remoteNotification: remoteNotification) {
            didReceiveProductNotification(note)
            Queue.main.after(NotificationCompletionHandlerDelay) {
                completionHandler(.Custom)
            }
        } else {
            completionHandler(.Default)
        }
    }
    
    // Will wait a little bit for the data to come in
    func didReceiveProductNotification(notification: PushNotification) {
        titleLabel.setText(notification.title)
        
        let request = NotificationDataRequest(
            category: notification.category,
            deeplink: notification.deeplink,
            responseDeserializer: deserializeProduct
        )
        
        let response = shared.session.execute(request, cache: notification.responseCache)
        
        response.onSuccess(ImmediateOnMainExecutionContext) { [weak self] (product: Product) in
            if let controller = self {
                controller.productOutlineFragment.update(controller.shared, executionContext: ImmediateExecutionContext, data: product)
            }
        }.onFailure { err in
            print(err)
        }
        
        if let location = BrowsingLocation.fromDeeplink(notification.deeplink) {
            self.updateUserActivity(location)
        }
    }
    
}