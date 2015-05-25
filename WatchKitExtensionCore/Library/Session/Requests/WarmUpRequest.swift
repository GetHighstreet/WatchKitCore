//
//  WarmUpRequest.swift
//  Pods
//
//  Created by Thomas Visser on 20/04/15.
//
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared
import Result

// Returns the local time of the phone, which is just a (lame) excuse to wake up the main app
struct WarmUpRequest: ParentAppRequest, Serializable {
    typealias ResponseType = NSDate
    
    let identifier = HSWatchKitWarmUpRequestIdentifier
    
    func jsonRepresentation() -> JSON {
        return JSON([:])
    }
    
    let responseDeserializer = { (json:JSON) in
        return json.int.map { int in
            return Result(value: (NSDate(timeIntervalSince1970: NSTimeInterval(int))))
        } ?? Result(error: Error.DeserializationFailed(object: json))
    }
}