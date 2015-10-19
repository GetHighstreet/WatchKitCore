//
//  ProductListInterfaceController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

/**
 * The interface controller for the product list screen (favorites and categories)
 */
class ProductListInterfaceController: WKInterfaceController {

    static let Identifier = "categoryProductList"
    
    struct ContentState {
        let numberOfProducts: Int?
        let receivedFirstProducts: Bool
    }
    
    @IBOutlet weak var headerGroup: WKInterfaceGroup!
    @IBOutlet weak var emptyStateGroup: WKInterfaceGroup!
    @IBOutlet weak var table: WKInterfaceTable!
    
    @IBOutlet weak var headerLeftLabel: WKInterfaceLabel!
    @IBOutlet weak var headerRightLabel: WKInterfaceLabel!
    
    @IBOutlet weak var promotionHeaderImage: WKInterfaceGroup!
    
    @IBOutlet weak var loadMoreGroup: WKInterfaceGroup!
    @IBOutlet weak var loadMoreButton: WKInterfaceButton!
    @IBOutlet weak var loadMoreIndicator: WKInterfaceImage!
    
    var context: ProductListInterfaceControllerContext!
    var tableController: TableController<Product>!
    var fetchController: FetchController<Product>!
    let updateQueue: Queue
    
    var contentState: ContentState {
        didSet {
            contentStateDidChange()
        }
    }
    
    override init() {
        contentState = ContentState(numberOfProducts: nil, receivedFirstProducts: false)
        
        updateQueue = Queue(queueLabel: "updateQueue")
        dispatch_set_target_queue(updateQueue.underlyingQueue, dispatch_get_main_queue())
        dispatch_suspend(updateQueue.underlyingQueue)
    }

    override func awakeWithContext(context: AnyObject?) {
        self.context = context as! ProductListInterfaceControllerContext
        
        fetchController = FetchController<Product>(batchSize: self.context.configuration.batchSize)
        fetchController.dataSource = self.context.configuration.fetchProductsInRange(self.context.shared)
        fetchController.addDataSourceCountListener { [weak self] count in
            self?.contentState = ContentState(numberOfProducts: count, receivedFirstProducts: true)
        }
        
        let tableConf = TableControllerConfiguration(
            fetchController: fetchController,
            table: table,
            rowAndColumnForObjectAtIndex: self.context.configuration.rowAndColumnForProductAtIndex,
            rowType: self.context.configuration.rowType,
            updateExecutionContext: updateQueue.context
        )
        
        tableController = TableController<Product>(configuration: tableConf, contextForObjectAtIndex: { [context = self.context] (product: Product, index: Int) -> ListRowControllerContext in
            return ListRowControllerContext(shared: context.shared) { [weak self] in
                self?.pushProductDetailsForProduct(product)
            }
        })
        
        // load the first product
        let firstProductFuture = fetchController.loadNextObjects(self.context.configuration.initialNumberOfProductsToLoad).onComplete { [weak self] _ in
            // show the more button
            self?.showMoreButtonIfNeeded()
        }
        
        // show promotionHeaderImage when applicable

        if let promotionHeaderImage = self.context.promotionHeaderImage  {
            
            self.promotionHeaderImage.setBackgroundColor(self.context.shared.theme.productBackgroundColor)
            
            self.context.shared.imageCache.ensureCacheImage(promotionHeaderImage).onSuccess { [weak self] in
                self?.promotionHeaderImage.setHidden(false)
                self?.promotionHeaderImage.setBackgroundImage($0)
            }
            
            firstProductFuture.onComplete { [weak self] _ in
                self?.loadRemainingProducts()
            }
        } else {
            if let rowController = tableController.controllerForRowAtIndex(0) as? SingleColumnRowController {
                rowController.setUp(self.context.shared)
                rowController.startRevealAnimation(self.context.shared)
                
                // only after the reveal animation started looping, we load the other products
                rowController.productOutlineFragment.revealFragment!.onReveal.onComplete { [weak self] _ in
                    self?.loadRemainingProducts()
                }
            } else {
                loadRemainingProducts()
            }
        }
    }
    
    func loadRemainingProducts() {
        if maxProductCount(context.configuration) > context.configuration.initialNumberOfProductsToLoad {
            self.fetchController.loadNextBatch()
        }
    }
    
    override func didAppear() {
        self.updateUserActivity(self.context.configuration.activity)
        dispatch_resume(updateQueue.underlyingQueue)
    }
    
    override func willDisappear() {
        dispatch_suspend(updateQueue.underlyingQueue)
    }
    
    func pushProductDetailsForProduct(product: Product) {
        pushControllerWithName(ProductDetailsInterfaceController.Identifier, context: self.contextForProductDetailsInterfaceControllerWithProduct(product))
    }
    
    func contextForProductDetailsInterfaceControllerWithProduct(product: Product) -> ProductDetailsInterfaceControllerContext {
        return context.detailsContextForProduct(product) { [weak self] product in
            self?.fetchController.updateObject(product)
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if let product = fetchController.objectAtIndex(rowIndex) {
            pushControllerWithName(
                ProductDetailsInterfaceController.Identifier,
                context: contextForProductDetailsInterfaceControllerWithProduct(product)
            )
        }
    }
    
    @IBAction func loadMoreProducts() {
        if !fetchController.isLoading {
            loadMoreButton.setHidden(true)
            
            let token = InvalidationToken()
            
            // show the loading indicator after 0.5 seconds
            Queue.main.after(.In(0.5)) {
                token.validContext { [weak self] in
                    self?.loadMoreIndicator.setImageNamed("loading_indicator")
                    let range = NSMakeRange(0, 50)
                    self?.loadMoreIndicator.startAnimatingWithImagesInRange(range, duration: NSTimeInterval(range.length)/25.0, repeatCount: Int.max)
                    self?.loadMoreIndicator.setHidden(false)
                }
            }
            
            fetchController.loadNextBatch().onComplete { [weak self] _ in
                token.invalidate()
                self?.loadMoreIndicator.setHidden(true)
                self?.loadMoreIndicator.stopAnimating()
                self?.showMoreButtonIfNeeded()
            }
        }
    }
    
    func showMoreButtonIfNeeded() {
        let thereIsMoreToLoad: Bool
        if let count = fetchController.dataSourceCount where fetchController.loadingRange.endIndex < min(count, maxProductCount(context.configuration)) {
            thereIsMoreToLoad = true
        } else {
            thereIsMoreToLoad = false
        }
        
        loadMoreGroup.setHidden(!thereIsMoreToLoad)
        loadMoreButton.setHidden(!thereIsMoreToLoad)
    }
    
    func contentStateDidChange() {
        if headerGroup != nil {
            updateHeader()
        }
        
        if emptyStateGroup != nil {
            updateEmptyState()
        }
    }
    
    func updateHeader() {
        let headerState = context.configuration.header(contentState)
        let visible = headerState.visible && contentState.receivedFirstProducts && contentState.numberOfProducts > 0
        let numberFormatter = NSNumberFormatter()
        
        if visible {
            if let count = headerState.count {
                if count <= maxProductCount(context.configuration) {
                    headerLeftLabel.setText(numberFormatter.stringFromNumber(NSNumber(integer: count)))
                } else {
                    headerLeftLabel.setText(numberFormatter.stringFromNumber(NSNumber(integer: maxProductCount(context.configuration))) + "+")
                }
            }
            headerLeftLabel.setHidden(headerState.count == nil)
            
            if let noun = headerState.noun {
                headerRightLabel.setText(noun)
            }
            
            headerRightLabel.setHidden(headerState.noun == nil)
        }
        headerGroup.setHidden(!visible)
    }

    func updateEmptyState() {
        emptyStateGroup.setHidden(contentState.numberOfProducts > 0)
    }
}

/**
 * The context for a product list interface controller.
 * The ProductListInterfaceController expects a context of this type
 *
 * The most important part of the context is the configuration. It dictates
 * the type of products and layout of the products.
 */
class ProductListInterfaceControllerContext: InterfaceControllerContext {

    let shared: SharedContextType
    let configuration: ProductListInterfaceControllerConfiguration
    var promotionHeaderImage : Image?
    
    init(context: InterfaceControllerContext, configuration: ProductListInterfaceControllerConfiguration, promotionHeaderImage: Image? = nil) {
        shared = context.shared
        self.configuration = configuration
        self.promotionHeaderImage = promotionHeaderImage
    }
    
    func detailsContextForProduct(product: Product, changeHandler: Product -> ()) -> ProductDetailsInterfaceControllerContext {
        return ProductDetailsInterfaceControllerContext(context: self, product: product, changeHandler: changeHandler)
    }
}

struct HeaderState {
    let visible: Bool
    let count: Int?
    let noun: String?
}

/**
* It would be nice to link to a specific ListRowController subclass, instead of
* needing to specify the rowType and the rowAndColumnForProductAtIndex: transformation,
* but in Swift 1.2 it is not yet possible
*/
protocol ProductListInterfaceControllerConfiguration {
    var initialNumberOfProductsToLoad: Int { get }
    var batchSize: Int { get }
    var maximumNumberOfBatches: Int { get }
    
    var header: ProductListInterfaceController.ContentState -> HeaderState { get }
    
    var rowType: String { get }
    
    var rowAndColumnForProductAtIndex: (Int) -> (Int, Int) { get }
    
    var fetchProductsInRange: SharedContextType -> Range<Int> -> Future<(Int, [Product]), Error> { get }
    
    var activity: UserActivity { get }
}

/**
 * The configuration for a product list interface controller. It is part of the context.
 */
struct FavoritesConfiguration: ProductListInterfaceControllerConfiguration {
    let initialNumberOfProductsToLoad = 2
    let batchSize = 6
    let maximumNumberOfBatches = 3
    
    let header = { (state:ProductListInterfaceController.ContentState) -> HeaderState in
        return HeaderState(
            visible: true,
            count: state.numberOfProducts,
            noun: state.numberOfProducts == 1 ? "Favorites.header.rightLabel.singular".localizedInWatchKitExtension : "Favorites.header.rightLabel.plural".localizedInWatchKitExtension
        )
    }
    let rowType = DualColumnRowController.Identifier
    
    var rowAndColumnForProductAtIndex = { (index:Int) -> (Int, Int) in
        let row = Int(floorf(Float(index) / Float(DualColumnRowController.columns)))
        let column = index % DualColumnRowController.columns
        
        return (row, column)
    }
    
    let fetchProductsInRange = { (context:SharedContextType) -> Range<Int> -> Future<(Int, [Product]), Error> in
        return { range -> Future<(Int, [Product]), Error> in
            let request = ProductListRequest(type: .Favorites, range: range)
            return context.session.execute(request)
        }
    }
    
    let activity = UserActivity.Browsing(location: .Favorites)
}

struct CategoryProductsConfiguration: ProductListInterfaceControllerConfiguration {
    let initialNumberOfProductsToLoad = 1
    let batchSize = 5
    let maximumNumberOfBatches = 3
    
    let header = { (state:ProductListInterfaceController.ContentState) -> HeaderState in
        return HeaderState(visible: false, count: nil, noun: nil)
    }
    
    let rowType = SingleColumnRowController.Identifier
    let fetchProductsInRange: SharedContextType -> Range<Int> -> Future<(Int, [Product]), Error>
    
    let activity: UserActivity
    
    init(categoryId: String) {
        self.fetchProductsInRange = { (context:SharedContextType) -> Range<Int> -> Future<(Int, [Product]), Error> in
                return { range -> Future<(Int, [Product]), Error> in
                    let request = ProductListRequest(type: .Category(id: categoryId), range: range)
                    return context.session.execute(request)
                }
        }
        
        activity = UserActivity.Browsing(location: .Category(id: categoryId))
    }
    
    var rowAndColumnForProductAtIndex = { (index:Int) -> (Int, Int) in
        return (index, 0)
    }
}

func maxProductCount(config: ProductListInterfaceControllerConfiguration) -> Int {
    return config.maximumNumberOfBatches * config.batchSize
}
