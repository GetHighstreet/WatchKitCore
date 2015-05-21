//
//  Range.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON

public func serialize(range: Range<Int>) -> String {
    return NSStringFromRange(NSMakeRange(range.startIndex, range.endIndex-range.startIndex))
}

public func adjacent<T>(rangeA: Range<T>, rangeB: Range<T>) -> Bool {
    return rangeA.startIndex == rangeB.endIndex || rangeA.endIndex == rangeB.startIndex
}

public func union<T: RandomAccessIndexType>(rangeA: Range<T>, rangeB: Range<T>) -> Range<T> {
    return min(rangeA.startIndex, rangeB.startIndex)..<max(rangeA.endIndex,rangeB.endIndex)
}

public func intersection(rangeA: Range<Int>, rangeB: Range<Int>) -> Range<Int>? {
    if max(rangeA.startIndex, rangeA.endIndex) < rangeB.startIndex
        || max(rangeB.startIndex, rangeB.endIndex) < rangeA.startIndex {
        return nil
    }
    
    return max(rangeA.startIndex, rangeB.startIndex)..<min(rangeA.endIndex, rangeB.endIndex)
}
