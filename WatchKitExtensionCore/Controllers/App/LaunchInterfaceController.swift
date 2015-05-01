//
//  LaunchInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures
import Shared

/**
 * The interface controller for the launch screen
 */
class LaunchInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var favoritesButton: WKInterfaceButton!
    @IBOutlet weak var favoritesButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var favoritesButtonLabel: WKInterfaceLabel!
    @IBOutlet weak var homePromotionsButton: WKInterfaceButton!
    @IBOutlet weak var homePromotionsButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var homePromotionsButtonBackgroundGroup: WKInterfaceGroup!
    @IBOutlet weak var homePromotionsButtonLabel: WKInterfaceLabel!
    
    var context: LaunchInterfaceControllerContext!
    
    override init() {
        context = LaunchInterfaceControllerContext()
        
        context.shared.session.execute(WarmUpRequest()).onComplete { _ in
            println("Warmed up!")
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        assert(context == nil)
        
        homePromotionsButtonBackgroundGroup.setBackgroundColor(self.context.shared.theme.tintColor1)
    }
    
    override func willActivate() {
        self.updateUserActivity(.Home)
    }
    
    override func didDeactivate() {
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        switch segueIdentifier {
            case "favorites":
                return context.favoritesContext()
            case "homePromotions":
                return HomePromotionsInterfaceControllerContext(context: context)
            default:
                fatalError("Segue \(segueIdentifier) not yet supported")
        }
    }
    
}

extension LaunchInterfaceController {
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        if let note = PushNotification(localNotification: localNotification) {
            handleActionWithIdentifier(identifier, forPushNotification: note)
        }
    }
    
    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        
        if let note = PushNotification(remoteNotification: remoteNotification) {
            handleActionWithIdentifier(identifier, forPushNotification: note)
        }
    }
    
    func handleActionWithIdentifier(identifier: String?, forPushNotification note: PushNotification) {
        switch note.category {
        case HSPushCategoryProduct:
            if let productId = note.subjectId {
                let context = ProductDetailsInterfaceControllerContext(context: self.context, productId:productId, action: identifier)
                self.pushControllerWithName("productDetails", context: context)
            }
        case HSPushCategoryCategory:
            if let categoryId = note.subjectId {
                let configuration = CategoryProductsConfiguration(categoryId: categoryId)
                self.pushControllerWithName(
                    ProductListInterfaceController.Identifier,
                    context: ProductListInterfaceControllerContext(context: self.context, configuration: configuration)
                )
            }
            return
        case HSPushCategoryLookbook:
            return
        case HSPushCategoryPromotion:
            let request = NotificationDataRequest(
                category: note.category,
                deeplink: note.deeplink,
                responseDeserializer: deserializeHomePromotionWithData,
                dummyResponse: Result.Failure(InfrastructureError.MissingDataSource.NSErrorRepresentation)
            )
            
            context.shared.session.execute(request, cache: note.responseCache).onSuccess { [unowned self] (promotion,_) in
                let configuration = CategoryProductsConfiguration(categoryId: promotion.categoryId)
                self.pushControllerWithName(
                    ProductListInterfaceController.Identifier,
                    context: ProductListInterfaceControllerContext(context: self.context, configuration: configuration, promotionHeaderImage: promotion.image)
                )
            }
            
        default:
            println("Could not handle action with identifier \(identifier) for push notification with category \(note.category)")
        }
    }
    
    override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        // this is only needed for the transition from a glance to the app, so not implemented right now
    }
}


class LaunchInterfaceControllerContext: InterfaceControllerContext {
    
    let shared: SharedContextType
    
    init() {
        shared = SharedContext.defaultContext()
    }
    
    func favoritesContext() -> ProductListInterfaceControllerContext {
        return ProductListInterfaceControllerContext(context: self, configuration: FavoritesConfiguration())
    }
    
}