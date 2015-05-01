//
//  Result.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures

func sequence<T>(seq: [Result<T>]) -> Result<[T]> {
    return seq.reduce(Result<[T]>.Success(Box([])), combine: { (res, elem) -> Result<[T]> in
        switch res {
            case .Success(let boxedResultSequence):
                switch elem {
                    case .Success(let boxedElemValue):
                        let newSeq = boxedResultSequence.value + [boxedElemValue.value]
                        return Result<[T]>.Success(Box(newSeq))
                    case .Failure(let elemError):
                        return Result<[T]>.Failure(elemError)
                }
            case .Failure(let err):
                return res
        }
    })
}

func NSRangeFromRange(range: Range<Int>) -> NSRange {
    return NSMakeRange(range.startIndex, range.endIndex - range.startIndex)
}