//
//  ParentAppRequest.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON
import BrightFutures
import Result

public protocol ParentAppRequest: Serializable {
    associatedtype ResponseType
    
    var identifier: String { get }
    
    var responseDeserializer: (JSON) -> Result<ResponseType, Error> { get }
}