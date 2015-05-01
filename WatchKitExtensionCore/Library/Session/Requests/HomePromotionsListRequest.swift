//
//  HomePromotionsListRequest.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 12/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared

struct HomePromotionsListRequest: ParentAppRequest {
    typealias ResponseType = [HomePromotion]
    
    let identifier = HSWatchKitHomePromotionsListRequestIdentifier
    
    init() {
        
    }
    
    func jsonRepresentation() -> JSON {
        return JSON([:])
    }
    
    let responseDeserializer = { (json:JSON) -> Result<[HomePromotion]> in
        if let promotionsArray = json.array {
            return sequence(promotionsArray.map(deserializeHomePromotion))
        }
        return Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
    }
    
    var dummyResponse: Result<[HomePromotion]> {
        let homePromotions = [
            HomePromotion(id: 1, categoryId: 2, image: Image.RemoteImage(url: "https://dl.dropboxusercontent.com/u/2196877/watchimages/1.jpg")),
            HomePromotion(id: 2, categoryId: 5, image: Image.RemoteImage(url: "https://dl.dropboxusercontent.com/u/2196877/watchimages/2.jpg")),
            HomePromotion(id: 3, categoryId: 12, image: Image.RemoteImage(url: "https://dl.dropboxusercontent.com/u/2196877/watchimages/3.jpg")),
            HomePromotion(id: 4, categoryId: 14, image: Image.RemoteImage(url: "https://dl.dropboxusercontent.com/u/2196877/watchimages/4.jpg")),
            HomePromotion(id: 5, categoryId: 20, image: Image.RemoteImage(url: "https://dl.dropboxusercontent.com/u/2196877/watchimages/5.jpg?z=1")),
        ]
        
        return Result.Success(Box(homePromotions))
    }
    
}