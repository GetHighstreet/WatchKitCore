//
//  Product.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared

protocol Identifiable {
    typealias Identifier: Equatable
    
    var identifier: Identifier { get }
}

struct Product: Identifiable {
    let id: Int
    let name: String?
    let secondaryAttribute: String?
    let price: String?
    var isFavorite: Bool
    
    let image: Image?
    
    private init?(json: JSON) {
        if let id = json[HSWatchKitResponseIdKey].int {
            self.id = id
            name = json[HSWatchKitResponseNameKey].string
            secondaryAttribute = json[HSWatchKitResponseSecondaryAttributeKey].string
            price = json[HSWatchKitResponsePriceKey].string
            isFavorite = json[HSWatchKitResponseFavoriteKey].boolValue
            
            image = deserializeImage(json[HSWatchKitResponseImageKey]).value
        } else {
            return nil
        }
    }
    
    init(id: Int, name: String? = nil, secondaryAttribute: String? = nil, price: String? = nil, image: Image? = nil, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.secondaryAttribute = secondaryAttribute
        self.price = price
        self.image = image
        self.isFavorite = isFavorite
    }
    
    func favoriteToggleAction() -> ProductFavoriteAction {
        if isFavorite {
            return .Remove
        }
        
        return .Add
    }

    var identifier: Int {
        return id
    }
}

func deserializeProduct(json: JSON) -> Result<Product> {
    return Product(json: json).map{
        Result.Success(Box($0))
    } ?? Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
}