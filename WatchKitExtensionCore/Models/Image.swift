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
import Result

public enum Image {
    case LocalImage(ref: LocalImageReference)
    case RemoteImage(url: String)
    
    var name: String {
        switch self {
        case .LocalImage(let ref):
            switch ref {
            case .InMemory(let name, _):
                return name
            case .Watch(let name):
                return name
            }
        case .RemoteImage(let url):
            return url
        }
    }
}

public enum LocalImageReference {
    case InMemory(name: String, image: UIImage)
    case Watch(name: String)
    
    var imageObject: UIImage? {
        switch self {
        case .InMemory(_, let image):
            return image
        case .Watch(_):
            return nil
        }
    }
}

func deserializeImage(json: JSON) -> Result<Image, Error> {
    switch json.type {
    case .String:
        return Result(value: Image.RemoteImage(url: json.stringValue))
    case .Dictionary:
        if
            let name = json[HSWatchKitResponseNameKey].string,
            let dataString = json[HSWatchKitResponseImageDataKey].string,
            let data = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0)),
            let image = UIImage(data: data)
        {
            return Result(value: .LocalImage(ref: LocalImageReference.InMemory(name: name, image: image)))
        }
        fallthrough
    default:
        return Result(error: .DeserializationFailed(object: json))
    }
}