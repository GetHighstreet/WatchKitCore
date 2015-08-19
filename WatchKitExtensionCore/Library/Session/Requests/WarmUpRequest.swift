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
public struct WarmUpRequest: ParentAppRequest, Serializable {
    public typealias ResponseType = NSDate
    
    public let identifier = HSWatchKitWarmUpRequestIdentifier
    
    public func jsonRepresentation() -> JSON {
        return JSON([:])
    }
    
    public let responseDeserializer = { (json:JSON) in
        return json.int.map { int in
            return Result(value: (NSDate(timeIntervalSince1970: NSTimeInterval(int))))
        } ?? Result(error: Error.DeserializationFailed(object: json))
    }
}