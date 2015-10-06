//
//  ListRowController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

protocol ListRowController {
    
    static var Identifier: String { get }
    static var columns: Int { get }
    
    func setUp(context: SharedContextType)
    
    func update(context: ListRowControllerContext, executionContext: ExecutionContext, object: Any, inColumn column: Int)
}

struct ListRowControllerContext {
    let shared: SharedContextType
    let didSelectColumn: (() -> ())?
}
