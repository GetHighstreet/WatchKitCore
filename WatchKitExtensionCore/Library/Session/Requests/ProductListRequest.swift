//
//  ProductListRequest.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared
import Result

public struct ProductListRequest: ParentAppRequest, Serializable {
    public typealias ResponseType = (Int, [Product])

    public let type: ProductListType
    public let range: Range<Int>
    
    public let identifier = HSWatchKitProductListRequestIdentifier
    
    init(type: ProductListType, range: Range<Int>) {
        self.type = type
        self.range = range
    }
    
    public func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestRangeKey: serialize(range),
            HSWatchKitRequestTypeKey: serialize(type),
        ])
    }
    
    public let responseDeserializer = deserializeCountAndProducts
}

func deserializeProducts(json: JSON) -> Result<[Product], Error> {
    if let productArray = json.array,
        products = sequence(productArray.map(deserializeProduct)).value  {
            
        return Result(value: products)
    }
    return Result(error: .DeserializationFailed(object: json))
}

func deserializeCountAndProducts(json: JSON) -> Result<(Int, [Product]), Error> {
    return deserializeProducts(json[HSWatchKitResponseItemsKey]).flatMap { (products:[Product]) in
        if let count = json[HSWatchKitResponseCountKey].int {
            return Result(value: (count, products))
        }
        return Result(error: .DeserializationFailed(object: json))
    }
}
