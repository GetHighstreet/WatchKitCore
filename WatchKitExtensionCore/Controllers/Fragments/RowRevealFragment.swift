//
//  RowRevealFragment.swift
//  Pods
//
//  Created by Thomas Visser on 19/04/15.
//
//

import Foundation
import WatchKit
import BrightFutures

protocol Revealing {
    mutating func startRevealAnimation(context: SharedContextType)
}

class RowRevealFragment: Revealing {
    
    var context: SharedContextType?
    
    let revealGroup: WKInterfaceGroup
    
    var imageSet: Promise<Void, Error>? = nil
    var revealDone: Future<Void, Error>? = nil
    var looping: Future<Void, Error>? = nil
    
    var onReveal: Future<Void, Error> {
        if let rev = revealDone {
            return rev
        }
        
        return Future(value: ())
    }
    
    var onLooping: Future<Void, Error> {
        if let looping = looping {
            return looping
        }
        
        return Future(value: ())
    }
    
    init(revealGroup: WKInterfaceGroup) {
        self.revealGroup = revealGroup
    }
    
    func startRevealAnimation(context: SharedContextType) {
        assert(self.imageSet == nil)
        self.context = context
        
        self.revealGroup.setBackgroundImageNamed("home_promotion_reveal")
        
        let fps = NSTimeInterval(25)
        let buildUpRange = NSMakeRange(0, 26)
        let loopRange = NSMakeRange(26, 50)
        let revealRange = NSMakeRange(76, 15)
        
        self.revealGroup.startAnimatingWithImagesInRange(
            buildUpRange,
            duration: NSTimeInterval(buildUpRange.length)/fps,
            repeatCount: 1
        )
        
        let imageSet = Promise<Void, Error>()
        
        let buildUpDelay = Future<Void, Error>(value: (), delay: (NSTimeInterval(buildUpRange.length)/fps)*1.5)
        
        looping = buildUpDelay.flatMap { [weak self] _ -> Future<Void, Error> in
            if !imageSet.future.isCompleted {
                self?.revealGroup.startAnimatingWithImagesInRange(
                    loopRange,
                    duration: NSTimeInterval(loopRange.length)/fps,
                    repeatCount: Int.max
                )
                
                return Future(value: ())
            }
            
            return Future(value: ())
        }
        
        self.imageSet = imageSet
        
        revealDone = buildUpDelay.zip(imageSet.future).flatMap { _ -> Future<Void, Error> in
            let duration = NSTimeInterval(revealRange.length)/fps
            
            self.revealGroup.startAnimatingWithImagesInRange(
                revealRange,
                duration: duration, repeatCount: 1
            )
            self.imageSet = nil
            
            return Future(value: (), delay: duration)
        }
    }
    
    func willSetImage(image: Image) -> Future<Void, Error> {
        if let context = context {
            if context.imageCache.cachedImageName(image) == nil {
                return onLooping
            }
        }
        
        return Future(value: ())
    }
    
    func didFinishLoading() {
        try! self.imageSet?.success()
    }
    
    
    
}