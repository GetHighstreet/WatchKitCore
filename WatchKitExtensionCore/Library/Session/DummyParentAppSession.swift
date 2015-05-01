//
//  DummyParentAppSession.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures

class DummyParentAppSession: ParentAppSession {
    
    func execute<R: ParentAppRequest>(request: R, cache: ResponseCache?) -> Future<R.ResponseType> {
        return execute(request)
    }
    
    func execute<R : ParentAppRequest>(request: R) -> Future<R.ResponseType> {
        return Future<R.ResponseType>.completed(request.dummyResponse).andThen(context: Queue.global.context) { res in
            NSThread.sleepForTimeInterval(NSTimeInterval(arc4random()%200)/NSTimeInterval(200))
        }
    }
    
}
