//
//  ChangeProductFavoriteStateRequest.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 10/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Shared

enum ProductFavoriteAction: Int {
    case Add = 1
    case Remove = 0
    
    var inverse: ProductFavoriteAction {
        switch self {
        case .Add:
            return .Remove
        case .Remove:
            return .Add
        }
    }
}


struct ChangeProductFavoriteStateRequest: ParentAppRequest, Serializable {
    typealias ResponseType = Bool
    
    let action: ProductFavoriteAction
    let productId: Int
    
    let identifier = HSWatchKitChangeProductFavoriteStateRequestIdentifier
    
    init(productId: Int, action: ProductFavoriteAction) {
        self.productId = productId
        self.action = action
    }
    
    func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestIdKey: productId,
            HSWatchKitRequestActionKey: action.rawValue
            ])
    }
    
    let responseDeserializer = { (json:JSON) -> Result<Bool> in
        return json.int.map {
            Result.Success(Box($0 == 1))
        } ?? Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
    }
}