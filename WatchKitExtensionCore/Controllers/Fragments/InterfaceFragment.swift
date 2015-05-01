//
//  InterfaceFragment.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 13/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation

/**
 * A fragment is a tiny controller for a recurring part of the interface
 * Upon creation, it should be bound to the appropriate IBOutlets.
 */
protocol InterfaceFragment {
    typealias DataType
    
    func setUp(context: SharedContextType)
    mutating func update(context: SharedContextType, data: DataType)
}