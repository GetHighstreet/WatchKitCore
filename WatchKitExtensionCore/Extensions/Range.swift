//
//  Range.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import SwiftyJSON

func serialize(range: Range<Int>) -> String {
    return NSStringFromRange(NSMakeRange(range.startIndex, range.endIndex-range.startIndex))
}

func adjacent<T>(rangeA: Range<T>, rangeB: Range<T>) -> Bool {
    return rangeA.startIndex == rangeB.endIndex || rangeA.endIndex == rangeB.startIndex
}

func union<T: RandomAccessIndexType>(rangeA: Range<T>, rangeB: Range<T>) -> Range<T> {
    return min(rangeA.startIndex, rangeB.startIndex)..<max(rangeA.endIndex,rangeB.endIndex)
}