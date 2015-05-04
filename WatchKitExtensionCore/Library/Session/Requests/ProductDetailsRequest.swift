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

struct ProductDetailsRequest: ParentAppRequest, Serializable {
    typealias ResponseType = ProductDetails
    
    let productId: Int
    
    let identifier = HSWatchKitProductDetailsRequestIdentifier
    
    init(productId: Int) {
        self.productId = productId
    }
    
    func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestIdKey: self.productId
        ])
    }
    
    let responseDeserializer = deserializeProductDetails
}
