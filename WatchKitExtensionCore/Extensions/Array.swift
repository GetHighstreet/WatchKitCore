//
//  Array.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON

public func validRange<E>(array: [E]) -> Range<Int> {
    return array.startIndex..<array.endIndex
}

func +<T>(var lhs: [T], rhs: T) -> [T] {
    lhs.append(rhs)
    return lhs
}