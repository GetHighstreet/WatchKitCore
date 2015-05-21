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

public struct HomePromotionsListRequest: ParentAppRequest {
    typealias ResponseType = [HomePromotion]
    
    public let identifier = HSWatchKitHomePromotionsListRequestIdentifier
    
    init() {
        
    }
    
    public func jsonRepresentation() -> JSON {
        return JSON([:])
    }
    
    public let responseDeserializer = { (json:JSON) -> Result<[HomePromotion]> in
        if let promotionsArray = json.array {
            return sequence(promotionsArray.map(deserializeHomePromotion))
        }
        return Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
    }
}