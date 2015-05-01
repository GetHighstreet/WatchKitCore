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
    
    func fetchImage(urlString: String) -> Future<LocalImageReference> {
        if let url = NSURL(string: urlString) {
            return fetchImageFromURL(url).map {
                return .InMemory(name: urlString, image: $0)
            }
        } else {
            return Future.failed(InfrastructureError.CFNetworkError(error: CFNetworkErrors.CFErrorHTTPBadURL).NSErrorRepresentation)
        }
    }
    
    private func fetchImageFromURL(url: NSURL) -> Future<UIImage> {
        let p = Promise<UIImage>()
        
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                p.failure(error)
            } else if let img = UIImage(data: data) {
                p.success(img)
            } else {
                p.failure(InfrastructureError.DeserializationFailed(object:data).NSErrorRepresentation)
            }
        })
        
        task.resume()
        
        return p.future
    }
    
}