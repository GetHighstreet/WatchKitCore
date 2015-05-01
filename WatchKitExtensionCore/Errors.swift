//
//  Errors.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation

protocol Error {
    var NSErrorRepresentation: NSError { get }
}

enum ErrorDomains: String {
    case InfrastructureErrorDomain = "HSWatchKitExtensionCoreInfrastructureErrorDomain"
}

let LazyError = NSError(domain: "HumanError", code: 42, userInfo: [NSLocalizedDescriptionKey: "There should be a better error here but the human was lazy"])

/**
 * All errors that can happen in the infrastructure layer
 */
enum InfrastructureError {
    case ParentAppCommunicationFailure
    case UnexpectedParentAppResponse(response: Any?)
    case DeserializationFailed(object: Any?)
    
    case MissingDataSource
    
    case ImageLoadingFailed(image: Image?)
    case WatchImageCacheAddingFailed(image: Image?)
    
    case CFNetworkError(error: CFNetworkErrors)
    
    case ParentAppResponseError(code: Int, description: String?)
}

extension InfrastructureError : Error {
    
    var NSErrorRepresentation: NSError {
        switch self {
        case .UnexpectedParentAppResponse(let response):
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Unexpected response from the parent application: \(response)"
            ])
        case .DeserializationFailed(let object):
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Failed to deserialize object: \(object)"
            ])
        case .MissingDataSource:
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 3, userInfo: [
                NSLocalizedDescriptionKey: "Could not load objects without a datasource"
            ])
        case .ParentAppCommunicationFailure:
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 4, userInfo: [
                NSLocalizedDescriptionKey: "Could not send request to parent app"
            ])
        case .ImageLoadingFailed(let image):
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 5, userInfo: [
                NSLocalizedDescriptionKey: "Could not load image \(image?.name)"
            ])
        case .WatchImageCacheAddingFailed(let image):
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 6, userInfo: [
                NSLocalizedDescriptionKey: "Could not add image \(image?.name) to cache"
            ])
        case .CFNetworkError(let error):
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 7, userInfo: [
                NSLocalizedDescriptionKey: "CFNetworkError: \(error.rawValue)"
            ])
        case .ParentAppResponseError(let code, let description):
            return NSError(domain: ErrorDomains.InfrastructureErrorDomain.rawValue, code: 7, userInfo: [
                NSLocalizedDescriptionKey: "Parent app returned error with code \(code), description: \(description)"
                ])
        }
    }
    
}