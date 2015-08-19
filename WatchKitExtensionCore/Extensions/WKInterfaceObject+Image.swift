//
//  WKInterfaceObject.swift
//  WatchKitExtensionCore
//
//  Created by Thomas Visser on 19/08/15.
//  Copyright © 2015 Highstreet. All rights reserved.
//

import UIKit
import WatchKit

protocol HasImage {
    func setImage(image: UIImage?)
    func setImageNamed(imageName: String?)
}

extension HasImage {
    
    func setImage(localImageReference: LocalImageReference) {
        if let image = localImageReference.imageObject {
            setImage(image)
        } else {
            setImageNamed(localImageReference.name)
        }
    }
    
}

protocol HasBackgroundImage {
    func setBackgroundImage(image: UIImage?)
    func setBackgroundImageNamed(imageName: String?)
}

extension HasBackgroundImage {
    func setBackgroundImage(localImageReference: LocalImageReference) {
        if let image = localImageReference.imageObject {
            setBackgroundImage(image)
        } else {
            setBackgroundImageNamed(localImageReference.name)
        }
    }
}

extension WKInterfaceImage: HasImage { }
extension WKInterfaceGroup: HasBackgroundImage { }