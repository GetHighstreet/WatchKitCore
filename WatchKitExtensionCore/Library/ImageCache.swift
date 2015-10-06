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

class ImageCache {
    
    private let device: WKInterfaceDevice

    private let fetcher: ImageFetcher
    private let cache: KingfisherImageCache
    private var scheduleSafeAccessLogToken: InvalidationToken?
    
    convenience init() {
        self.init(device: WKInterfaceDevice.currentDevice())
    }
    
    init(device: WKInterfaceDevice, fetcher: ImageFetcher = ImageFetcher()) {
        self.device = device
        self.cache = KingfisherImageCache(name: "imageCache")
        self.cache.maxDiskCacheSize = 10 * 1024 * 1024
        self.cache.maxMemoryCost = 4 * 1024 * 1024
        self.fetcher = fetcher
    }
    
    func ensureCacheImage(image: Image) -> Future<LocalImageReference, Error> {
        return cachedImage(image) ?? self.cacheImage(image)
    }
    
    private func cacheImage(image: Image) -> Future<LocalImageReference, Error> {
        switch image {
        case .RemoteImage(let url):
            return fetcher.fetchImage(url).flatMap {
                self.cacheImage(image.name, localImageReference: $0)
            }
        case .LocalImage(let ref):
            return Future<LocalImageReference, Error>(result: cacheImage(image.name, localImageReference: ref))
        }
    }
    
    private func cacheImage(name: String, localImageReference ref: LocalImageReference) -> Result<LocalImageReference, Error> {
        if let image = ref.imageObject {
            cache.storeImage(image, forKey: ref.name)
            return Result(value: ref)
        } else {
            return Result(error: .ImageLoadingFailed(image: nil))
        }
    }
    
    // Returns the name to use for the given image if it is cached
    func cachedImage(image: Image) -> Future<LocalImageReference, Error> {
        let p = Promise<LocalImageReference, Error>()
        cache.retrieveImageForKey(image.name, options: KingfisherManager.OptionsNone) { cachedImage, _ in
            guard let cachedImage = cachedImage else {
                p.failure(.Unspecified)
                return
            }
            
            p.success(.InMemory(name: image.name, image: cachedImage))
        }
        return p.future
    }
    
    func cleanExpiredDiskCache() {
        cache.cleanExpiredDiskCache()
    }
    
    func clearMemoryCache() {
        cache.clearMemoryCache()
    }
    
    func hasCachedImage(image: Image) -> Bool {
        return cache.isImageCachedForKey(image.name).cached
    }
}
