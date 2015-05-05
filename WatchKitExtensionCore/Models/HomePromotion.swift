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

public struct HomePromotion: Identifiable {
    let id: Int
    let categoryId: Int
    let image: Image?
    
    public var identifier: Int {
        return id
    }
    
    public init(id: Int, categoryId: Int, image: Image) {
        self.id = id
        self.categoryId = categoryId
        self.image = image
    }
    
    init?(json: JSON) {
        if let id = json[HSWatchKitResponseIdKey].int, categoryId = json[HSWatchKitResponseCategoryIdKey].int {
            self.id = id
            self.categoryId = categoryId
            
            self.image = deserializeImage(json[HSWatchKitResponseImageKey]).value
        } else {
            return nil
        }
    }
}

func deserializeHomePromotion(json: JSON) -> Result<HomePromotion> {
    return HomePromotion(json: json).map{
        Result.Success(Box($0))
        } ?? Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
}

func deserializeHomePromotionWithData(json: JSON) -> Result<(HomePromotion,(Int, [Product]))> {
    
    return deserializeCountAndProducts(json[HSWatchKitResponseProductsKey]).flatMap { productsAndCount in
        deserializeHomePromotion(json[HSWatchKitResponseHomePromotionKey]).map { (homePromotion) in
            (homePromotion,productsAndCount)
        }
    }
    
    
}