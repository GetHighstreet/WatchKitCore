//
//  ProductListType.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import Shared

public enum ProductListType {
    case Category(id: Int)
    case Favorites
}

func serialize(type: ProductListType) -> [String:AnyObject] {
    switch type {
    case .Category(let id):
        return [
            HSWatchKitRequestTypeKey: HSWatchKitProductListTypeCategory,
            HSWatchKitRequestIdKey: id
        ]
    case .Favorites:
        return [
            HSWatchKitRequestTypeKey: HSWatchKitProductListTypeFavorites
        ]
    }
}