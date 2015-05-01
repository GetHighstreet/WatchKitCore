//
//  WKInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit

extension WKInterfaceController {

    func updateUserActivity(activity: UserActivity) {
        updateUserActivity(activity.type, userInfo: activity.userInfo, webpageURL: nil)
    }
    
    func updateUserActivity(browsingLocation: BrowsingLocation) {
        let activity = UserActivity.Browsing(location: browsingLocation)
        updateUserActivity(activity.type, userInfo: activity.userInfo, webpageURL: nil)
    }
    
}