//
//  InterfaceControllerContext.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation

protocol InterfaceControllerContext {
    var shared: SharedContextType { get }
}

protocol SharedContextType {
    var session: ParentAppSession { get }
    var imageCache: ImageCache { get }
    var theme: StoreTheme { get }
}

struct SharedContext: SharedContextType {
    let session: ParentAppSession
    let imageCache: ImageCache
    let theme: StoreTheme
    
    static func dummyContext() -> SharedContextType {
        return SharedContext(
            session: DummyParentAppSession(),
            imageCache: ImageCache(),
            theme: StoreTheme.fromJSON() ?? StoreTheme.developmentTheme()
        )
    }
    
    static func defaultContext() -> SharedContextType {
        return realContext()
    }
    
    private static func realContext() -> SharedContextType {
        return SharedContext(
            session: _ParentAppSession(),
            imageCache: ImageCache(),
            theme: {
                let theme = StoreTheme.fromJSON()
                assert(theme != nil, "Theme could not be loaded from JSON")
                return theme ?? StoreTheme.developmentTheme()
            }()
        )
    }
}