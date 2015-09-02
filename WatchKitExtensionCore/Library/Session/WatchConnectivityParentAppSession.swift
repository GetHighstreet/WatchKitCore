//
//  WatchConnectivityParentAppSession.swift
//  WatchKitExtensionCore
//
//  Created by Thomas Visser on 18/08/15.
//  Copyright © 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures
import WatchKit
import SwiftyJSON
import Shared
import Result
import WatchConnectivity

class WatchConnectivityParentAppSession: ParentAppSession {
    
    let session: WCSession
    
    init() {
        self.session = WCSession.defaultSession()
    }
    
    required init(session: WCSession) {
        self.session = session
    }
    
    func execute<R : ParentAppRequest>(request: R) -> Future<R.ResponseType, Error> {
        let p = Promise<R.ResponseType, Error>()
        
        let message: [String:AnyObject] = [
            HSWatchKitRequestIdentifierKey: request.identifier,
            HSWatchKitRequestParametersKey: request.jsonRepresentation().object ?? [:]
        ]
        
        session.sendMessage(message, replyHandler: { response -> Void in
            p.tryComplete(self.parseResponse(JSON(response), forRequest: request).flatten())
        }, errorHandler: { error -> Void in
            p.tryFailure(.External(error: error))
        })
        
        return p.future
    }
    
    // The outer Result represents the parsing, the inner result the contents of the response
    func parseResponse<R: ParentAppRequest>(response: JSON, forRequest request: R) -> Result<Result<R.ResponseType, Error>, Error> {
        let success = response[HSWatchKitResponseSuccessKey]
        if success.error == nil {
            if success.boolValue || success.intValue == 1 {
                let value = response[HSWatchKitResponseValueKey]
                if value.error == nil {
                    return request.responseDeserializer(value).map { response in
                        return Result(value: response)
                    }
                }
            } else {
                if let error = response[HSWatchKitResponseErrorKey].dictionaryObject {
                    let errorJSON = JSON(error)
                    if let code = errorJSON[HSWatchKitResponseErrorCodeKey].int {
                        let description = errorJSON[HSWatchKitResponseErrorDescriptionKey].string
                        return Result(value: Result(error: .ParentAppResponseError(code: code, description: description)))
                    }
                }
            }
        }
        
        return Result(error: .UnexpectedParentAppResponse(response: response))
    }
}