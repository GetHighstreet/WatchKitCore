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
import Result

public protocol Identifiable {
    associatedtype Identifier: Equatable
    
    var identifier: Identifier { get }
}

public struct Product: Identifiable {
    public let id: String
    public let name: String?
    public let secondaryAttribute: String?
    public let price: String?
    public var isFavorite: Bool
    
    let image: Image?
    
    private init?(json: JSON) {
        if let id = json[HSWatchKitResponseIdKey].string {
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
    
    public init(id: String, name: String? = nil, secondaryAttribute: String? = nil, price: String? = nil, image: Image? = nil, isFavorite: Bool = false) {
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

    public var identifier: String {
        return id
    }
}

func deserializeProduct(json: JSON) -> Result<Product, Error> {
    return Product(json: json).map{
        Result(value: $0)
    } ?? Result(error: .DeserializationFailed(object: json))
}