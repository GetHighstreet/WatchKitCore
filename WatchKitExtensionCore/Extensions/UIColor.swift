//
//  UIColor.swift
//  Pods
//
//  Created by Thomas Visser on 20/04/15.
//
//

import Foundation
import UIKit

extension UIColor {
    
    // from https://gist.github.com/arshad/de147c42d7b3063ef7bc
    static func fromHex(hex: String) -> UIColor? {
        let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet().mutableCopy() as! NSMutableCharacterSet
        characterSet.formUnionWithCharacterSet(NSCharacterSet(charactersInString: "#"))
        let cString = hex.stringByTrimmingCharactersInSet(characterSet).uppercaseString
        
        if (cString.characters.count != 6) {
            return nil
        } else {
            var rgbValue: UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)
            
            return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0))
        }
    }
    
}