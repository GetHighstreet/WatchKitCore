//
//  ResponseCache.swift
//  Pods
//
//  Created by Thomas Visser on 18/04/15.
//
//

import Foundation
import BrightFutures
import SwiftyJSON
import Shared

protocol ResponseCacheType {
    typealias CacheValueType
    
    func responseForRequest<R: ParentAppRequest>(request: R) -> CacheValueType?
}

struct JSONResponseCache: ResponseCacheType {
    
    typealias CacheEntry = (request: Request, response: JSON)
    
    struct Request: Equatable {
        let identifier: String
        let parameters: JSON
        
        init?(json: JSON) {
            if let identifier = json[HSWatchKitRequestIdentifierKey].string {
                let parameters = json[HSWatchKitRequestParametersKey]
                if parameters.type == .Dictionary {
                    self.identifier = identifier
                    self.parameters = parameters
                    return
                }
            }
            
            return nil
        }
    }
    
    let cacheEntries: [CacheEntry]
    
    init?(json: JSON) {
        if let embeddedResponses = json.array {
            var entries = [CacheEntry]()
            
            for entry in embeddedResponses {
                let requestJSON = entry[HSWatchKitPushNotificationEmbeddedResponsesRequestKey]
                let responseJSON = entry[HSWatchKitPushNotificationEmbeddedResponsesResponseKey]
                
                if let request = Request(json: requestJSON) {
                    entries.append(request: request, response: responseJSON)
                }
            }
            
            cacheEntries = entries
            return
        }
        
        return nil
    }
    
    /**
     * Returns nil if the response is not found, 
     * returns .Success if the response is found and could be deserialized
     * returns .Failure if the response is
     */
    func responseForRequest<R: ParentAppRequest>(request: R) -> JSON? {
        for entry in cacheEntries {
            if entry.request == request {
                return entry.response
            }
        }
        
        return nil
    }
    
}

func ==(lhs: JSONResponseCache.Request, rhs: JSONResponseCache.Request) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.parameters == rhs.parameters
}

func ==<R: ParentAppRequest>(lhs: JSONResponseCache.Request, rhs: R) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.parameters == rhs.jsonRepresentation()
}