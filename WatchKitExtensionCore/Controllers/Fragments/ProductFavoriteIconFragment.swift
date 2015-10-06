//
//  ProductFavoriteIconFragment.swift
//  Pods
//
//  Created by Thomas Visser on 16/04/15.
//
//

import Foundation
import WatchKit
import BrightFutures

struct ProductFavoriteIconFragmentData {
    let isFavorite: Bool
    let animated: Bool
}

struct ProductFavoriteIconFragment: InterfaceFragment {
    
    let image: WKInterfaceImage
    var displayingFavorite = false
    
    init(image: WKInterfaceImage) {
        self.image = image
    }
    
    func setUp(context: SharedContextType) {
        image.setHidden(true)
    }
    
    mutating func update(context: SharedContextType, executionContext: ExecutionContext, data: ProductFavoriteIconFragmentData) {
        if data.isFavorite == displayingFavorite {
            return
        }
        
        if data.isFavorite {
            image.setHidden(false)
        }
        
        if data.animated {
            let (name, range, duration) = infoForAnimationToFavoriteState(data.isFavorite)
            image.setImageNamed(name)
            image.startAnimatingWithImagesInRange(range, duration: duration, repeatCount: 1)
        } else {
            if !data.isFavorite {
                image.setHidden(true)
            } else {
                image.setImageNamed(infoForAnimationToFavoriteState(!data.isFavorite).0)
            }
        }
        
        displayingFavorite = data.isFavorite
    }
    
    func infoForAnimationToFavoriteState(isFavorite: Bool) -> (String, NSRange, NSTimeInterval) {
        if isFavorite {
            return ("favorite_icon_in", NSMakeRange(0,23), 0.92)
        } else {
            return ("favorite_icon_out", NSMakeRange(0,17), 0.68)
        }
    }
    
}