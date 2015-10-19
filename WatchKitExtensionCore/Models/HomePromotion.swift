//
//  HomePromotion.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 10/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared
import Result

public struct HomePromotion: Identifiable {
    public let id: Int
    public let categoryId: String
    public let image: Image?
    
    public var identifier: Int {
        return id
    }
    
    public init(id: Int, categoryId: String, image: Image) {
        self.id = id
        self.categoryId = categoryId
        self.image = image
    }
    
    init?(json: JSON) {
        if let id = json[HSWatchKitResponseIdKey].int, categoryId = json[HSWatchKitResponseCategoryIdKey].string {
            self.id = id
            self.categoryId = categoryId
            
            self.image = deserializeImage(json[HSWatchKitResponseImageKey]).value
        } else {
            return nil
        }
    }
}

func deserializeHomePromotion(json: JSON) -> Result<HomePromotion, Error> {
    return HomePromotion(json: json).map{
        Result(value: $0)
    } ?? Result(error: .DeserializationFailed(object: json))
}

func deserializeHomePromotionWithData(json: JSON) -> Result<(HomePromotion,(Int, [Product])), Error> {
    
    return deserializeCountAndProducts(json[HSWatchKitResponseProductsKey]).flatMap { productsAndCount in
        deserializeHomePromotion(json[HSWatchKitResponseHomePromotionKey]).map { (homePromotion) in
            (homePromotion,productsAndCount)
        }
    }
    
    
}