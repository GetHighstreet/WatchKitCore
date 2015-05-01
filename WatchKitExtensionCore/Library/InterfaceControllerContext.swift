//
//  InterfaceControllerContext.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON

let SharedContextJSONSessionKey = "session"
let SharedContextJSONDummySessionValue = "dummy"
let SharedContextJSONDefaultSessionValue = "default"
let SharedContextJSONThemeKey = "theme"

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
    
    static func defaultContext() -> SharedContext {
        if let context = fromJSON() {
            return context
        }
        
        fatalError("Cannot create the default context, check your configuration.json")
    }
    
    static func fromJSON(resourceName: String = "configuration") -> SharedContext? {
        if let path =  NSBundle.mainBundle().pathForResource(resourceName, ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let json = JSON(data: jsonData, options: NSJSONReadingOptions(0), error: nil)
                return self.fromJSON(json)
            } else {
                println("Could not load data from \(resourceName).json")
            }
        } else {
            println("Could not find \(resourceName).json in main bundle")
        }
        
        return nil
    }
    
    static func fromJSON(json: JSON) -> SharedContext? {
        if json.type == .Dictionary {
            let theme = StoreTheme.fromJSON(json[SharedContextJSONThemeKey]) ?? StoreTheme.developmentTheme()
            
            let session: ParentAppSession
            
            switch json[SharedContextJSONSessionKey].stringValue {
            case SharedContextJSONDefaultSessionValue:
                session = _ParentAppSession()
            case SharedContextJSONDummySessionValue:
                session = DummyParentAppSession()
            default:
                println("Value for key \(SharedContextJSONSessionKey) should be \(SharedContextJSONDefaultSessionValue) or \(SharedContextJSONDummySessionValue)")
                return nil
            }
            
            return SharedContext(session: session, imageCache: ImageCache(), theme: theme)
        } else {
            println("Could not create context from JSON: \(json)")
            return nil
        }
    }
}