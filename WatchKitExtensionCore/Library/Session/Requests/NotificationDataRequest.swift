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
import Result

public struct NotificationDataRequest<R>: ParentAppRequest {
    
    public let category: String
    public let deeplink: String
    public let responseDeserializer: JSON -> Result<R, Error>

    public var identifier: String {
        return HSWatchKitNotificationRequestIdentifierPrefix + category
    }
    
    public func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestDeeplinkKey: self.deeplink,
        ])
    }
    
}