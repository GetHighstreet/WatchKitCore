//
//  StoreTheme.swift
//  Pods
//
//  Created by Thomas Visser on 20/04/15.
//
//

import Foundation
import SwiftyJSON
import UIKit

let StoreThemeJSONProductBackgroundKey = "productBackgroundColor"
let StoreThemeJSONTintColor1Key = "tintColor1"
let StoreThemeJSONTintColor2Key = "tintColor2"

protocol StoreThemeType {
    
}

struct StoreTheme {
    let productBackgroundColor: UIColor
    let tintColor1: UIColor
    let tintColor2: UIColor
    
    static func developmentTheme() -> StoreTheme {
        return StoreTheme(
            productBackgroundColor: UIColor.whiteColor(),
            tintColor1: UIColor.blueColor(),
            tintColor2: UIColor.orangeColor()
        )
    }
    
    static func fromJSON(resourceName: String = "theme") -> StoreTheme? {
        if let path =  NSBundle.mainBundle().pathForResource(resourceName, ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                let json = JSON(data: jsonData, options: NSJSONReadingOptions(0), error: nil)
                return fromJSON(json)
            } else {
                println("Could not load data from \(resourceName).json")
            }
        } else {
            println("Could not find \(resourceName).json in main bundle")
        }
        
        return nil
    }
    
    static func fromJSON(json: JSON) -> StoreTheme? {
        if json.type == .Dictionary {
            if let
                bgColor = UIColor.fromHex(json[StoreThemeJSONProductBackgroundKey].stringValue),
                tintColor1 = UIColor.fromHex(json[StoreThemeJSONTintColor1Key].stringValue),
                tintColor2 = UIColor.fromHex(json[StoreThemeJSONTintColor2Key].stringValue)
            {
                return StoreTheme(
                    productBackgroundColor: bgColor,
                    tintColor1: tintColor1,
                    tintColor2: tintColor2
                )
            }
        }
        
        println("Could not create theme from JSON: \(json)")
        return nil
    }
}