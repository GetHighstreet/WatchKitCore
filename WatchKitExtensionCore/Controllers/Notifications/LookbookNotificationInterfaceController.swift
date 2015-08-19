//
//  ProductNotificationInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Christian Apers on 19/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import SwiftyJSON
import BrightFutures


class LookbookNotificationInterfaceController: WKUserNotificationInterfaceController {
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var lookbookImageGroup: WKInterfaceGroup!
    @IBOutlet weak var placeholderImageGroup: WKInterfaceGroup!

    let shared: SharedContextType
    
    override init() {
        shared = SharedContext.defaultContext()
    }
    
    func setUp() {
        placeholderImageGroup.setBackgroundImageNamed("product_placeholder")
        lookbookImageGroup.setBackgroundColor(shared.theme.productBackgroundColor)
    }
    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: (WKUserNotificationInterfaceType) -> Void) {
        setUp()
        
        if let notification = PushNotification(localNotification: localNotification) {
            didReceiveLookbookNotification(notification)
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
            didReceiveLookbookNotification(notification)
            Queue.main.after(NotificationCompletionHandlerDelay) {
                completionHandler(.Custom)
            }
        } else {
            completionHandler(.Default)
        }
    }
    
    func didReceiveLookbookNotification(notification: PushNotification) {
        titleLabel.setText(notification.title)
        
        let request = NotificationDataRequest(
            category: notification.category,
            deeplink: notification.deeplink,
            responseDeserializer: deserializeImage
        )
        
        let response = shared.session.execute(request, cache: notification.responseCache)


        
        response.onSuccess(ImmediateOnMainExecutionContext) { [weak self] (image: Image) in
                        self?.shared.imageCache.ensureCacheImage(image).onSuccess { name in
                        self?.placeholderImageGroup.setBackgroundImageNamed(nil)
                        self?.lookbookImageGroup.setBackgroundImageNamed(name)
            }
        }.onFailure { err in
            print(err)
        }
        
        if let location = BrowsingLocation.fromDeeplink(notification.deeplink) {
            self.updateUserActivity(location)
        }
        
    }


}