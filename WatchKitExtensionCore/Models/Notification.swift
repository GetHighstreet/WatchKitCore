//
//  Notification.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Shared

let NotificationPayloadAppleKey = "aps"
let NotificationPayloadCategoryKey = "category"
let NotificationPayloadAlertKey = "alert"
let NotificationPayloadHighstreetKey = "hs"
let NotificationPayloadDeeplinkKey = "d"

public struct PushNotification {
    let title: String?
    let category: String
    let deeplink: String
    let responseCache: JSONResponseCache?
    
    // the id of the subject (often the last part of the deeplink)
    var subjectId: Int? {
        return Int((deeplink as NSString).lastPathComponent)
    }
    
    init?(localNotification: UILocalNotification) {
        if let userInfo = localNotification.userInfo.map({ JSON($0) }) {
            if
                let category = localNotification.category,
                let deeplink = userInfo[NotificationPayloadHighstreetKey][NotificationPayloadDeeplinkKey].string
            {
                self.title = localNotification.alertBody
                self.category = category
                self.deeplink = deeplink
                self.responseCache = JSONResponseCache(json: userInfo[NotificationPayloadHighstreetKey][HSWatchKitPushNotificationEmbeddedResponses])
                return
            }
        }
        
        return nil
    }
    
    init?(remoteNotification: [NSObject : AnyObject]) {
                let userInfo = JSON(remoteNotification)
        
        if
            let category = userInfo[NotificationPayloadAppleKey][NotificationPayloadCategoryKey].string,
            let deeplink = userInfo[NotificationPayloadHighstreetKey][NotificationPayloadDeeplinkKey].string
        {
            self.title = userInfo[NotificationPayloadAppleKey][NotificationPayloadAlertKey].string
            self.category = category
            self.deeplink = deeplink
            self.responseCache = JSONResponseCache(json: userInfo[NotificationPayloadHighstreetKey][HSWatchKitPushNotificationEmbeddedResponses])
            return
        }
        
        return nil
    }
}