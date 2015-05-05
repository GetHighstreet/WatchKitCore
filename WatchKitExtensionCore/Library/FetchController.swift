//
//  FetchController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 08/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import BrightFutures

class FetchController<T: Identifiable> {
    
    // configuration
    let batchSize: Int
    
    // internals
    var data = [T?]()
    var dataSource: (Range<Int> -> Future<(Int, [T])>)?
    
    var insertionListeners = Array<((T,Int) -> Void)>()
    var updateListeners = Array<((T,Int) -> Void)>()
    var dataSourceCountListeners = Array<(Int? -> Void)>()
    
    /// includes indexes that are already loaded (so will always start with 0)
    var loadingRange = 0..<0
    /// will always start with 0
    var loadedRange = 0..<0
    
    var dataSourceCount: Int? {
        didSet {
            for listener in dataSourceCountListeners {
                listener(dataSourceCount)
            }
        }
    }
    
    init(batchSize: Int) {
        self.batchSize = batchSize
    }
    
    func addInsertionListener(listener: (T, Int) -> ()) {
        insertionListeners.append(listener)
    }
    
    func addUpdateListener(listener: (T, Int) -> ()) {
        updateListeners.append(listener)
    }
    
    func addDataSourceCountListener(listener: Int? -> ()) {
        dataSourceCountListeners.append(listener)
    }
    
    /// Loads the next batch. If the next batch has already been loaded partially,
    /// that batch will be the next batch and its remaining objects will be loaded
    func loadNextBatch() -> Future<Void> {
        return loadRange(rangeToLoadForNextBatch())
    }
    
    func loadNextObjects(count: Int) -> Future<Void> {
        return loadRange(loadingRange.endIndex..<loadingRange.endIndex+count)
    }
    
    func rangeToLoadForNextBatch() -> Range<Int> {
        let numberOfBatchesFullyLoaded = loadingRange.endIndex / self.batchSize
        let objectsLoadedOfNextBatch = loadingRange.endIndex - numberOfBatchesFullyLoaded * self.batchSize
        
        assert(objectsLoadedOfNextBatch < self.batchSize, "impossible")
        
        return loadingRange.endIndex..<loadingRange.endIndex+batchSize-objectsLoadedOfNextBatch
    }
    
    private func loadRange(range: Range<Int>) -> Future<Void> {
        if let dataSource = dataSource {
            assert(adjacent(loadingRange, range), "The newly requested objects should be adjacent to the once already loading/loaded")
            loadingRange = union(loadingRange, range)
            
            return dataSource(range).flatMap { [weak self] (count, objects) -> Future<Void> in
                if let controller = self {
                    if adjacent(controller.loadedRange, range) {
                        controller.didReceiveObjects(objects, forRange: range)
                        if controller.dataSourceCount != count {
                            controller.dataSourceCount = count
                        }
                        return Future.succeeded()
                    }
                }
                
                return Future.failed(LazyError)
            }.onFailure { [weak self] err in
                self?.loadingRange = loadingRange.startIndex..<range.startIndex
            }
        }
        
        return Future<Void>.failed(InfrastructureError.MissingDataSource.NSErrorRepresentation)
    }
    
    var isLoading: Bool {
        return loadingRange != loadedRange
    }
    
    func didReceiveObjects(objects: [T], forRange range: Range<Int>) {
        assert(adjacent(loadedRange, range), "The newly received objects should be adjacent to the once already loaded")
        
        for (i, object) in enumerate(objects) {
            setObject(object, atIndex: i + range.startIndex)
        }
        
        loadedRange = union(loadedRange, range)
    }
    
    func setObject(object: T, atIndex index: Int) {
        if let currentObjectAtIndex = objectAtIndex(index) {
            // todo: check if object is the same
            data[index] = object
            didUpdateObject(object, atIndex: index)
        } else {
            ensureCapacityOfDataArrayForIndex(index)
            data[index] = object
            didInsertObject(object, atIndex: index)
        }
    }
    
    func ensureCapacityOfDataArrayForIndex(index: Int) {
        if index >= data.count {
            for i in data.count...index {
                data.append(nil)
            }
        }
    }
    
    func objectAtIndex(index: Int) -> T? {
        if index < data.count {
            return data[index]
        }
        return nil
    }
    
    func indexOfObjectWithIdentifier(identifier: T.Identifier) -> Int? {
        for (index,object) in enumerate(data) {
            if object?.identifier == identifier {
                return index
            }
        }
        
        return nil
    }
    
    func didInsertObject(object: T, atIndex index: Int) {
        for insertionListener in insertionListeners {
            insertionListener(object, index)
        }
    }
    
    func didUpdateObject(object: T, atIndex index: Int) {
        for updateListener in updateListeners {
            updateListener(object, index)
        }
    }
}