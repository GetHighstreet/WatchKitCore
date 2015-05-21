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

public enum ProductFavoriteAction: Int {
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


public struct ChangeProductFavoriteStateRequest: ParentAppRequest, Serializable {
    typealias ResponseType = Bool
    
    public let action: ProductFavoriteAction
    public let productId: Int
    
    public let identifier = HSWatchKitChangeProductFavoriteStateRequestIdentifier
    
    init(productId: Int, action: ProductFavoriteAction) {
        self.productId = productId
        self.action = action
    }
    
    public func jsonRepresentation() -> JSON {
        return JSON([
            HSWatchKitRequestIdKey: productId,
            HSWatchKitRequestActionKey: action.rawValue
            ])
    }
    
    public let responseDeserializer = { (json:JSON) -> Result<Bool> in
        return json.int.map {
            Result.Success(Box($0 == 1))
        } ?? Result.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
    }
}