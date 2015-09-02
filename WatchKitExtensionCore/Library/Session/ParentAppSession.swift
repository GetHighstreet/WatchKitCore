//
//  ParentAppSession.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures
import WatchKit
import SwiftyJSON
import Shared
import Result

public protocol ParentAppSession {
    
    func execute<R: ParentAppRequest>(request: R) -> Future<R.ResponseType, Error>

    func parseResponse<R: ParentAppRequest>(response: JSON, forRequest request: R) -> Result<Result<R.ResponseType, Error>, Error>
    
}

extension ParentAppSession {
    func execute<R: ParentAppRequest, C: ResponseCacheType where C.CacheValueType == JSON>(request: R, cache: C?) -> Future<R.ResponseType, Error> {
        if let cache = cache, cachedResponse = cache.responseForRequest(request)   {
            return Future<R.ResponseType, Error>(result: parseResponse(cachedResponse, forRequest: request).flatten())
        } else {
            return execute(request)
        }
    }
}
