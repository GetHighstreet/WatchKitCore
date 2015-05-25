//
//  Result.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures
import Result

func sequence<T, E>(seq: [Result<T, E>]) -> Result<[T], E> {
    return seq.reduce(Result(value: []), combine: { (res, elem) -> Result<[T], E> in
        switch res {
            case .Success(let boxedResultSequence):
                switch elem {
                    case .Success(let boxedElemValue):
                        let newSeq = boxedResultSequence.value + [boxedElemValue.value]
                        return Result(value: newSeq)
                    case .Failure(let boxedElemError):
                        return Result<[T], E>(error: boxedElemError.value)
                }
            case .Failure(let err):
                return res
        }
    })
}

func NSRangeFromRange(range: Range<Int>) -> NSRange {
    return NSMakeRange(range.startIndex, range.endIndex - range.startIndex)
}