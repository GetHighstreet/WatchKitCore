//
//  ExtensionDelegate.swift
//  WatchKitExtensionCore
//
//  Created by Thomas Visser on 17/08/15.
//  Copyright © 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity
import Shared

public class ExtensionDelegate: NSObject, WCSessionDelegate {
    
    let session: WCSession
    let sharedContext = SharedContext.defaultContext()
    
    var rootInterfaceController: LaunchInterfaceController {
        return WKExtension.sharedExtension().rootInterfaceController as! LaunchInterfaceController
    }
    
    override init() {
        self.session = WCSession.defaultSession()
        
        super.init()
        
        self.session.delegate = self
        self.session.activateSession()
    }
}

extension ExtensionDelegate: WKExtensionDelegate {

    public static func sharedDelegate() -> ExtensionDelegate {
        return WKExtension.sharedExtension().delegate! as! ExtensionDelegate
    }
    
    public func applicationDidFinishLaunching() {
        print("did finish launching")
    }
    
    public func applicationDidBecomeActive() {
        print("did become active")
    }
    
    public func applicationWillResignActive() {
        sharedContext.imageCache.clearMemoryCache()
        sharedContext.imageCache.cleanExpiredDiskCache()
    }
    
    public func didReceiveLocalNotification(notification: UILocalNotification) {
        print("did receive local notification, what to do?")
    }
    
    public func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        print("did receive remote notification, what to do?")
    }
    
    public func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        if let note = PushNotification(localNotification: localNotification) {
            handleActionWithIdentifier(identifier, forPushNotification: note)
        }
    }
    
    public func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        
        if let note = PushNotification(remoteNotification: remoteNotification) {
            handleActionWithIdentifier(identifier, forPushNotification: note)
        }
    }
    
    public func handleActionWithIdentifier(identifier: String?, forPushNotification note: PushNotification) {
        switch note.category {
        case HSPushCategoryProduct:
            if let productId = note.subjectId {
                rootInterfaceController.showProductDetails(productId, actionIdentifier: identifier)
            }
        case HSPushCategoryCategory:
            if let categoryId = note.subjectId {
                rootInterfaceController.showCategory(categoryId)
            }
            return
        case HSPushCategoryLookbook:
            return
        case HSPushCategoryPromotion:
            let request = NotificationDataRequest(
                category: note.category,
                deeplink: note.deeplink,
                responseDeserializer: deserializeHomePromotionWithData
            )
            
            sharedContext.session.execute(request, cache: note.responseCache).onSuccess { [unowned self] (promotion,_) in
                self.rootInterfaceController.showCategory(promotion.categoryId, promotionHeaderImage: promotion.image)
            }
            
        default:
            print("Could not handle action with identifier \(identifier) for push notification with category \(note.category)")
        }
    }
    
    public func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        // this is only needed for the transition from a glance to the app, so not implemented right now
    }
    
}