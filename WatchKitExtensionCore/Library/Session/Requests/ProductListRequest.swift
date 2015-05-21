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

public struct ProductListRequest: ParentAppRequest, Serializable {
    typealias ResponseType = (Int, [Product])

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

func deserializeProducts(json: JSON) -> Result<[Product]> {
    if let productArray = json.array,
        products = sequence(productArray.map(deserializeProduct)).value  {
            
        return Result.Success(Box(products))
    }
    return Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
}

func deserializeCountAndProducts(json: JSON) -> Result<(Int, [Product])> {
    return deserializeProducts(json[HSWatchKitResponseItemsKey]).flatMap { (products:[Product]) in
        if let count = json[HSWatchKitResponseCountKey].int {
            return Result.Success(Box(count, products))
        }
        return Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
    }
}
