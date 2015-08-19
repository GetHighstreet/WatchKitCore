//
//  ImageCache.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures
import Result

typealias ImageAccessLog = [String]

private let UserDefaultsImageAccessLogKey = "com.highstreet.watchkitextension.ImageCache.accessLog"
private let AccessLogSaveDelay = 2.0;

class ImageCache {
    
    private let device: WKInterfaceDevice
    private let evictionPolicy: EvictionPolicy
    private let fetcher: ImageFetcher
    private var accessLog: ImageAccessLog = ImageAccessLog()
    private var scheduleSafeAccessLogToken: InvalidationToken?
    
    convenience init() {
        self.init(device: WKInterfaceDevice.currentDevice())
    }
    
    init(device: WKInterfaceDevice, evictionPolicy: EvictionPolicy = DefaultEvictionPolicy, fetcher: ImageFetcher = ImageFetcher()) {
        self.device = device
        self.evictionPolicy = evictionPolicy
        self.fetcher = fetcher
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let storedAccessLog = userDefaults.objectForKey(UserDefaultsImageAccessLogKey) as? ImageAccessLog {
            // filter out the images that are not in the Watch' cache anymore & add the ones that are missing
            accessLog = sync(storedAccessLog, cachedImages: cachedImages)
            scheduleSafeAccessLog()
        }
    }
    
    func ensureCacheImage(image: Image) -> Future<String, Error> {
        accessLog = add(image, log: accessLog)
        scheduleSafeAccessLog()
        return cachedImageName(image).map { Future(value: $0) } ?? cacheImage(image)
    }
    
    private func cacheImage(image: Image) -> Future<String, Error> {
        switch image {
        case .RemoteImage(let url):
            return fetcher.fetchImage(url).flatMap {
                self.cacheImage(image.name, localImageReference: $0)
            }
        case .LocalImage(let ref):
            return Future<String, Error>(result: cacheImage(image.name, localImageReference: ref))
        }
    }
    
    private func cacheImage(name: String, localImageReference ref: LocalImageReference) -> Result<String, Error> {
        if let _ = ref.imageObject {
//            while !self.device.addCachedImage(img, name: name) {
//                if let imageToEvict = self.evictionPolicy(accessLog, self.cachedImages) {
//                    self.device.removeCachedImageWithName(imageToEvict)
//                    accessLog = remove(.LocalImage(ref: .Watch(name: imageToEvict)), log: accessLog)
//                    scheduleSafeAccessLog()
//                } else {
//                    return Result(error: .WatchImageCacheAddingFailed(image: nil))
//                }
//            }
        
            return Result(value: name)
        } else {
            return Result(error: .ImageLoadingFailed(image: nil))
        }
    }
    
    // Returns the name to use for the given image if it is cached
    func cachedImageName(image: Image) -> String? {
        return self.cachedImages[image.name].map { _ in image.name }
    }
    
    func clearCache() {
        //self.device.removeAllCachedImages()
    }
    
    var cachedImages: [String:Int] {
        return [:];//self.device.cachedImages as! [String:Int]
    }
    
    func scheduleSafeAccessLog() {
        try! scheduleSafeAccessLogToken?.invalidate()
        scheduleSafeAccessLogToken = InvalidationToken()
        
        Future<Void, NoError>(value: (), delay: AccessLogSaveDelay).onComplete(token: scheduleSafeAccessLogToken!) { [weak self] _ in
            self?.saveAccessLog()
        }
    }
    
    func saveAccessLog() {        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(accessLog, forKey: UserDefaultsImageAccessLogKey)
        userDefaults.synchronize()
    }
    
}

// The eviction policy will return the name of the image to remove from the cache
typealias EvictionPolicy = (ImageAccessLog, [String:Int]) -> String?

let DefaultEvictionPolicy: EvictionPolicy = { log, images in
    // return the 'stalest' image that is still in cache
    for name in log {
        if images.indexForKey(name) != nil {
            return name
        }
    }
    
    // return a random image
    if images.count > 0 {
        let (key, _) = images[images.startIndex]
        return key
    }
    
    return nil
}

/// Removes the images from the access log that are not in the cached images
/// and adds the images from the cache that are not in the log to the tail of the log
func sync(accessLog: ImageAccessLog, cachedImages: [String:Int]) -> ImageAccessLog {
    let filteredLog = accessLog.filter { cachedImages.indexForKey($0) != nil }
    
    return cachedImages.keys.filter { filteredLog.indexOf($0) == nil} + filteredLog
}

func remove(image: Image, log: ImageAccessLog) -> ImageAccessLog {
    return log.filter { $0 != image.name }
}

func add(image: Image, log: ImageAccessLog) -> ImageAccessLog {
    return remove(image, log: log) + image.name
}