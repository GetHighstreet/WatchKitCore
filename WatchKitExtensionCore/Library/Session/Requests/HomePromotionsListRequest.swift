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
}