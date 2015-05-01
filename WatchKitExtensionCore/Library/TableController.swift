//
//  TableController.swift
//  HighstreetWatchKitExtensionCore
//
//  Created by Thomas Visser on 10/04/15.
//  Copyright (c) 2015 Highstreet. All rights reserved.
//

import Foundation
import WatchKit

struct TableControllerConfiguration<T: Identifiable> {
    
    let fetchController: FetchController<T>
    let table: WKInterfaceTable
    
    let rowAndColumnForObjectAtIndex: Int -> (Int, Int)
    let rowType: String
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
            let (row, column) = configuration.rowAndColumnForObjectAtIndex(index)
            let rowController = configuration.table.rowControllerAtIndex(row) as! ListRowController
            
            let context = contextForObjectAtIndex(object, index)
            
            rowController.update(context, object: object, inColumn: column)
        }
        
        configuration.fetchController.addInsertionListener(self.fetchControllerDidInsertObject)
        configuration.fetchController.addUpdateListener(self.update)
        
        configuration.table.setNumberOfRows(0, withRowType: "")
    }
    
    func fetchControllerDidInsertObject(object: T, atIndex index: Int) {
        ensureRowAvailabilityForIndex(index)
     
        // set-up
        let (row, column) = configuration.rowAndColumnForObjectAtIndex(index)
        let rowController = configuration.table.rowControllerAtIndex(row) as! ListRowController
        let context = contextForObjectAtIndex(object, index)
        rowController.setUp(context.shared)
        
        // first update
        self.update(object, index)
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
    
}