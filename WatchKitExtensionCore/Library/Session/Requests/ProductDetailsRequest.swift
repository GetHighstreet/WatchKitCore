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
    
    var dummyResponse: Result<ProductDetails> {
        get {
            return Result.Success(Box(ProductDetails(product: dummyProducts[productId-1], description: "Wie kent de DSW stoel van Vitra niet... DSW staat voor Dining Height Side Chair Wooden Base. Maar deze stoel laat zich liever DSW noemen. Dat zit wat makkelijker. Zijn organisch gevormde zitschaal van kunststof zorgt ervoor dat je ontspannen en comfortabel op de DSW stoel zit. Kortom, de Vitra Eames DSW stoel is de ideale eetkamerstoel, met een prachtig houten onderstel van esdoorn.")))
        }
    }
}
