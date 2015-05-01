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

struct ProductListRequest: ParentAppRequest, Serializable {
    typealias ResponseType = (Int, [Product])

    let type: ProductListType
    let range: Range<Int>
    
    let identifier = HSWatchKitProductListRequestIdentifier
    
    init(type: ProductListType, range: Range<Int>) {
        self.type = type
        self.range = range
    }
    
    func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestRangeKey: serialize(range),
            HSWatchKitRequestTypeKey: serialize(type),
        ])
    }
    
    let responseDeserializer = deserializeCountAndProducts
    
    var dummyResponse: Result<(Int,[Product])> {
        get {
            let productSlice = dummyProducts[range.startIndex..<min(range.endIndex,dummyProducts.count)]
            
            let res = (10, Array(productSlice))
            return Result.Success(Box(res))
        }
    }
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

let dummyProducts = [
    Product(id: 1, name: "Amp Lamp hanglamp small", secondaryAttribute: "Normann Copenhagen", price: "€ 107", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/n/o/normann-copenhagen-amp-lamp-hanglamp-small-groen-goud-600x600.jpg"), isFavorite: false),
    Product(id: 2, name: "Eames DSR stoel met verchroomd onderstel", secondaryAttribute: "Vitra", price: "€ 229", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/v/i/vit-dsr-stoel-wit-600x600.jpg"), isFavorite: false),
    Product(id: 3, name: "About a Chair AAC22 stoel", secondaryAttribute: "Hay", price: "€ 236", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/h/a/hay-aac22-eiken-wit-600x600.jpg"), isFavorite: false),
    Product(id: 4, name: "Pinocchio vloerkleed multi colour", secondaryAttribute: "Hay", price: "€ 244", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/h/a/hay-pinocchio-multi-600x600.jpg"), isFavorite: false),
    Product(id: 5, name: "Amp Lamp hanglamp small", secondaryAttribute: "Normann Copenhagen", price: "€ 107", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/n/o/normann-copenhagen-amp-lamp-hanglamp-small-groen-goud-600x600.jpg"), isFavorite: false),
    Product(id: 6, name: "Eames DSR stoel met verchroomd onderstel", secondaryAttribute: "Vitra", price: "€ 229", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/v/i/vit-dsr-stoel-wit-600x600.jpg"), isFavorite: false),
    Product(id: 7, name: "About a Chair AAC22 stoel", secondaryAttribute: "Hay", price: "€ 236", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/h/a/hay-aac22-eiken-wit-600x600.jpg"), isFavorite: false),
    Product(id: 8, name: "Pinocchio vloerkleed multi colour", secondaryAttribute: "Hay", price: "€ 244", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/h/a/hay-pinocchio-multi-600x600.jpg"), isFavorite: false),
    Product(id: 9, name: "Amp Lamp hanglamp small", secondaryAttribute: "Normann Copenhagen", price: "€ 107", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/n/o/normann-copenhagen-amp-lamp-hanglamp-small-groen-goud-600x600.jpg"), isFavorite: false),
    Product(id: 10, name: "Eames DSR stoel met verchroomd onderstel", secondaryAttribute: "Vitra", price: "€ 229", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/v/i/vit-dsr-stoel-wit-600x600.jpg"), isFavorite: false),
    Product(id: 11, name: "About a Chair AAC22 stoel", secondaryAttribute: "Hay", price: "€ 236", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/h/a/hay-aac22-eiken-wit-600x600.jpg"), isFavorite: false),
    Product(id: 12, name: "Pinocchio vloerkleed multi colour", secondaryAttribute: "Hay", price: "€ 244", image: .RemoteImage(url: "http://www.flinders.nl/media/catalog/product/cache/1/image/471x/9df78eab33525d08d6e5fb8d27136e95/h/a/hay-pinocchio-multi-600x600.jpg"), isFavorite: false),
]