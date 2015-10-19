//
//  ProductDetailsRequest.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared

public struct ProductDetailsRequest: ParentAppRequest, Serializable {
    public typealias ResponseType = ProductDetails
    
    public let productId: String
    
    public let identifier = HSWatchKitProductDetailsRequestIdentifier
    
    init(productId: String) {
        self.productId = productId
    }
    
    public func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestIdKey: self.productId
        ])
    }
    
    public let responseDeserializer = deserializeProductDetails
}
