//
//  Future.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures

extension Future {
    
    func runAndAwait(until: TimeInterval = .Forever) -> Result<T>? {
        
        while until.dispatchTime > dispatch_time(DISPATCH_TIME_NOW, 0) {
            for mode in [NSRunLoopCommonModes, NSDefaultRunLoopMode] {
                NSRunLoop.currentRunLoop() .runMode(mode, beforeDate: NSDate(timeIntervalSinceNow: 10))
            }
            
            if let result = self.result {
                return result
            }
        }
        
        return nil
    }
    
}