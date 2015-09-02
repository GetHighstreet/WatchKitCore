//
//  UserActivity.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import Shared

enum UserActivity {
    case Browsing(location: BrowsingLocation)
    
    var type: String {
        switch self {
        case .Browsing(_):
            return HSWatchKitUserActivityTypeBrowsing
        }
    }
    
    var userInfo: [NSString:AnyObject] {
        switch self {
        case .Browsing(let loc):
            return [
                HSWatchKitUserActivityBrowsingDeeplinkKey: loc.deeplink()
            ]
        }
    }
}

enum BrowsingLocation {
    case Home
    case Category(id: Int)
    case Product(id: Int)
    case ProductInCategory(categoryId: Int, productId: Int)
    case Favorites
    case Lookbook(id: Int)
    case HomePromotion(id: Int)
    
    case Other(path: String)
    
    func deeplink(scheme: String = "activity") -> String {
        switch self {
        case .Home:
            return "\(scheme)://home"
        case .Category(let id):
            return "\(scheme)://categories/\(id)"
        case .Product(let id):
            return "\(scheme)://products/\(id)"
        case ProductInCategory(let cid, let pid):
            return "\(scheme)://categories/\(cid)/products/\(pid)"
        case Favorites:
            return "\(scheme)://favorites"
        case .HomePromotion(let id):
            return "\(scheme)://home/promotions/\(id)"
        case .Lookbook(let id):
            return "\(scheme)://lookbooks/\(id)"
        case .Other(let path):
            return "\(scheme)://\(path)"
        }
    }
    
    static func fromDeeplink(link: String) -> BrowsingLocation? {
        if let schemeEnd = link.rangeOfString("//") {
            let path = link.substringFromIndex(schemeEnd.endIndex.advancedBy(1))
            return .Other(path: path)
        }
        return nil
    }
}