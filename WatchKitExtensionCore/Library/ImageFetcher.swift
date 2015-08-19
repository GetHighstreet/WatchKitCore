//
//  ImageFetcher.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 09/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures
import UIKit

class ImageFetcher {
    
    let urlSession: NSURLSession
    
    init() {
        urlSession = NSURLSession.sharedSession()
    }
    
    func fetchImage(urlString: String) -> Future<LocalImageReference, Error> {
        if let url = NSURL(string: urlString) {
            return fetchImageFromURL(url).map {
                return .InMemory(name: urlString, image: $0)
            }
        } else {
            return Future(error: .ImageLoadingFailed(image: nil))
        }
    }
    
    private func fetchImageFromURL(url: NSURL) -> Future<UIImage, Error> {
        let p = Promise<UIImage, Error>()
        
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                try! p.failure(.External(error: error))
            } else if let data = data, img = UIImage(data: data) {
                try! p.success(img)
            } else {
                try! p.failure(.DeserializationFailed(object:data))
            }
        })
        
        task.resume()
        
        return p.future
    }
    
}