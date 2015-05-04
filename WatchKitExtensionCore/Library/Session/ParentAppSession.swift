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

public protocol ParentAppSession {
    init()
    
    func execute<R: ParentAppRequest>(request: R) -> Future<R.ResponseType>
    func execute<R: ParentAppRequest>(request: R, cache: ResponseCache?) -> Future<R.ResponseType>
}

class _ParentAppSession : ParentAppSession {
    
    required init() {
        
    }
    
    func execute<R: ParentAppRequest>(request: R, cache: ResponseCache?) -> Future<R.ResponseType> {
        if let cache = cache,cachedResponse = cache.responseForRequest(request)   {
            return Future<R.ResponseType>.completed(flatten(parseResponse(cachedResponse, forRequest: request)))
        } else {
            return execute(request)
        }
    }
    
    func execute<R: ParentAppRequest>(request: R) -> Future<R.ResponseType> {
        return _execute(request, retry: true)
    }
    
    func _execute<R: ParentAppRequest>(request: R, retry: Bool) -> Future<R.ResponseType> {
        let p = Promise<R.ResponseType>()

        let userInfo: [NSObject:AnyObject] = [
            HSWatchKitRequestIdentifierKey: request.identifier,
            HSWatchKitRequestParametersKey: request.jsonRepresentation().object ?? [:]
        ]
        
        let sent = WKInterfaceController.openParentApplication(userInfo, reply: { (response, error) -> Void in
            if let error = error {
                p.failure(error)
            } else if let response = response {
                p.complete(flatten(self.parseResponse(JSON(response), forRequest: request)))
            } else {
                if retry {
                    println("retrying request")
                    p.completeWith(self._execute(request, retry: false))
                } else {
                    p.failure(InfrastructureError.UnexpectedParentAppResponse(response: nil).NSErrorRepresentation)
                }
            }
        })
        
        if !sent {
            if retry {
                println("retrying request")
                p.completeWith(_execute(request, retry: false))
            } else {
                p.failure(InfrastructureError.ParentAppCommunicationFailure.NSErrorRepresentation)
            }
        }
        
        p.future.onFailure { err in
            println(err)
        }
        
        return p.future
    }
    
    // The outer Result represents the parsing, the inner result the contents of the response
    func parseResponse<R: ParentAppRequest>(response: JSON, forRequest request: R) -> Result<Result<R.ResponseType>> {
        let success = response[HSWatchKitResponseSuccessKey]
        if success.error == nil {
            if success.boolValue || success.intValue == 1 {
                let value = response[HSWatchKitResponseValueKey]
                if value.error == nil {
                    return request.responseDeserializer(value).map { response in
                        return Result.Success(Box(response))
                    }
                }
            } else {
                if let error = response[HSWatchKitResponseErrorKey].dictionaryObject {
                    let errorJSON = JSON(error)
                    if let code = errorJSON[HSWatchKitResponseErrorCodeKey].int {
                        let description = errorJSON[HSWatchKitResponseErrorDescriptionKey].string
                        return Result.Success(Box(Result.Failure(InfrastructureError.ParentAppResponseError(code: code, description: description).NSErrorRepresentation)))
                    }
                }
            }
        }
        
        return Result.Failure(InfrastructureError.UnexpectedParentAppResponse(response: response).NSErrorRepresentation)
    }
}