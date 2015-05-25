//
//  ProductDetails.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyJSON
import Shared
import Result

public struct ProductDetails {
    var product: Product
    let description: String?
    
    public init(product: Product, description: String? = nil) {
        self.product = product
        self.description = description
    }
    
    init?(json: JSON) {
        if let product = deserializeProduct(json).value {
            self.product = product
            self.description = json[HSWatchKitResponseDescriptionKey].string
        } else {
            return nil
        }
    }
}

func deserializeProductDetails(json: JSON) -> Result<ProductDetails, Error> {
    return ProductDetails(json: json).map {
        Result(value: $0)
    } ?? Result(error: .DeserializationFailed(object: json))
}