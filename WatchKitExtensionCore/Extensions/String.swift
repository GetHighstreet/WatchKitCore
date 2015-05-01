//
//  String.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation

func +(lhs: String?, rhs: String) -> String {
    if let lhs = lhs {
        return lhs + rhs
    }
    
    return rhs
}

func +(lhs: String, rhs: String?) -> String {
    if let rhs = rhs {
        return lhs + rhs
    }
    
    return lhs
}

extension String {
    var localizedInWatchKitExtension: String {
        return NSLocalizedString(self, bundle: NSBundle(forClass: LaunchInterfaceController.self), comment: "")
    }
}