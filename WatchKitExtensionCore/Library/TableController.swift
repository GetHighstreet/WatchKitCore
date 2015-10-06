//
//  TableController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 10/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit
import BrightFutures

struct TableControllerConfiguration<T: Identifiable> {
    
    let fetchController: FetchController<T>
    let table: WKInterfaceTable
    
    let rowAndColumnForObjectAtIndex: Int -> (Int, Int)
    let rowType: String
    
    let updateExecutionContext: ExecutionContext
}

// Connects a fetch controller and a WKInterfaceTable
class TableController<T: Identifiable> {
    let configuration: TableControllerConfiguration<T>
    let update: (T, Int) -> ()
    let contextForObjectAtIndex: (T, Int) -> ListRowControllerContext
    
    init(configuration: TableControllerConfiguration<T>, contextForObjectAtIndex: (T, Int) -> ListRowControllerContext) {
        self.configuration = configuration
        self.contextForObjectAtIndex = contextForObjectAtIndex
        
        self.update = { object, index in
            configuration.updateExecutionContext {
                let (row, column) = configuration.rowAndColumnForObjectAtIndex(index)
                let rowController = configuration.table.rowControllerAtIndex(row) as! ListRowController
                
                let context = contextForObjectAtIndex(object, index)
                
                rowController.update(context, executionContext: configuration.updateExecutionContext, object: object, inColumn: column)
            }
        }
        
        configuration.fetchController.addInsertionListener(self.fetchControllerDidInsertObject)
        configuration.fetchController.addUpdateListener(self.update)
        
        configuration.table.setNumberOfRows(0, withRowType: "")
    }
    
    func fetchControllerDidInsertObject(object: T, atIndex index: Int) {
        ensureRowAvailabilityForIndex(index)
        updateObjectAtIndex(index)
    }
    
    func ensureRowAvailabilityForIndex(index: Int) {
        let (rowIndex, _) = configuration.rowAndColumnForObjectAtIndex(index)
        
        if rowIndex >= configuration.table.numberOfRows {
            let rangeToInsert = configuration.table.numberOfRows...rowIndex
            
            if !rangeToInsert.isEmpty {
                let indexSet = NSIndexSet(indexesInRange: NSRangeFromRange(rangeToInsert))
                configuration.table.insertRowsAtIndexes(indexSet, withRowType: configuration.rowType)
            }
        }
    }
    
    func controllerForRowAtIndex(index: Int) -> ListRowController {
        ensureRowAvailabilityForIndex(index)
        return configuration.table.rowControllerAtIndex(index) as! ListRowController
    }
    
    func updateObjectAtIndex(index: Int) {
        if let object = configuration.fetchController.objectAtIndex(index) {
            // set-up
            let (row, _) = configuration.rowAndColumnForObjectAtIndex(index)
            let rowController = configuration.table.rowControllerAtIndex(row) as! ListRowController
            let context = contextForObjectAtIndex(object, index)
            rowController.setUp(context.shared)
            
            // first update
            self.update(object, index)
        }
    }
    
    func reloadData() {
        for i in 0..<configuration.fetchController.numberOfObjects() {
            ensureRowAvailabilityForIndex(i)
            updateObjectAtIndex(i)
        }
    }
}