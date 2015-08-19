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
let SharedContextJSONDefaultSessionValue = "__default"
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
        let json = fromJSON()
        
        return SharedContext(session: json.0 ?? WatchConnectivityParentAppSession(), imageCache: ImageCache(), theme: json.1 ?? StoreTheme.developmentTheme())
    }
    
    static func fromJSON(resourceName: String = "configuration") -> (ParentAppSession?, StoreTheme?) {
        if let path =  NSBundle.mainBundle().pathForResource(resourceName, ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let json = JSON(data: jsonData, options: NSJSONReadingOptions(rawValue: 0), error: nil)
                return self.fromJSON(json)
            } else {
                print("Could not load data from \(resourceName).json")
            }
        } else {
            print("Could not find \(resourceName).json in main bundle")
        }
        
        return (nil, nil)
    }
    
    static func fromJSON(json: JSON) -> (ParentAppSession?, StoreTheme?) {
        if json.type == .Dictionary {
            let theme = StoreTheme.fromJSON(json[SharedContextJSONThemeKey]) ?? StoreTheme.developmentTheme()
            
            let session: ParentAppSession
            
            switch json[SharedContextJSONSessionKey].stringValue {
            case "": // no value
                fallthrough
            case SharedContextJSONDefaultSessionValue:
                session = WatchConnectivityParentAppSession()
            case let s: // the default
                if let customSession = NSClassFromString(s) as? NSObject.Type {
                    if let s = customSession.init() as? ParentAppSession {
                        session = s
                        break
                    }
                }
                
                print("Value for key \(SharedContextJSONSessionKey) should be \(SharedContextJSONDefaultSessionValue) or or a class name that implements ParentAppSession and NSObject")
                return (nil, theme)
            }
            
            return (session, theme)
        } else {
            print("Could not create context from JSON: \(json)")
            return (nil, nil)
        }
    }
}
