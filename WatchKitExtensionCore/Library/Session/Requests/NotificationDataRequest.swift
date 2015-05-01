//
//  NotificationDataRequest.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON
import Shared

struct NotificationDataRequest<R>: ParentAppRequest {
    
    let category: String
    let deeplink: String
    let responseDeserializer: JSON -> Result<R>
    let dummyResponse: Result<R>

    var identifier: String {
        return HSWatchKitNotificationRequestIdentifierPrefix + category
    }
    
    func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestDeeplinkKey: self.deeplink,
        ])
    }
    
}