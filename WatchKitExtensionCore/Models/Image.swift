//
//  Image.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures
import SwiftyJSON
import Shared

enum Image {
    case LocalImage(ref: LocalImageReference)
    case RemoteImage(url: String)
    
    var name: String {
        switch self {
        case .LocalImage(let ref):
            switch ref {
            case .InMemory(let name, _):
                return name
            case .Extension(let name, let bundle):
                return bundle?.bundleIdentifier + name
            case .Watch(let name):
                return name
            }
        case .RemoteImage(let url):
            return url
        }
    }
}

enum LocalImageReference {
    case InMemory(name: String, image: UIImage)
    case Extension(name: String, bundle: NSBundle?)
    case Watch(name: String)
    
    var imageObject: UIImage? {
        switch self {
        case .InMemory(_, let image):
            return image
        case .Extension(let name, let bundle):
            return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        case .Watch(let name):
            return nil
        }
    }
}

enum DisplayImage {
    case StillImage(ref: LocalImageReference)
    case AnimatedImage(ref: LocalImageReference, range: NSRange, duration: NSTimeInterval, repeat: Int)
}


func deserializeImage(json: JSON) -> Result<Image> {
    switch json.type {
    case .String:
        return Result<Image>.Success(Box(Image.RemoteImage(url: json.stringValue)))
    case .Dictionary:
        if
            let name = json[HSWatchKitResponseNameKey].string,
            let dataString = json[HSWatchKitResponseImageDataKey].string,
            let data = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0)),
            let image = UIImage(data: data)
        {
            return Result<Image>.Success(Box(.LocalImage(ref: LocalImageReference.InMemory(name: name, image: image))))
        }
        fallthrough
    default:
        return Result<Image>.Failure(InfrastructureError.DeserializationFailed(object: json).NSErrorRepresentation)
    }
}