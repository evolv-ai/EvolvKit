//
//  EvolvExecutionQueue.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

class EvolvExecutionQueue {
    
    private let logger = EvolvLogger.shared
    
    private var queue: [EvolvExecutable] = []
    var count: Int {
        return queue.count
    }
    
    init() {}
    
    static let shared = EvolvExecutionQueue()
    
    func enqueue<T>(_ execution: EvolvExecution<T>) {
        queue.insert(execution, at: 0)
    }
    
    func executeAllWithValues(from rawAllocations: EvolvRawAllocations) throws {
        while !queue.isEmpty {
            guard let execution = queue.popLast() else {
                continue
            }
            
            do {
                try execution.execute(with: rawAllocations)
            } catch {
                logger.debug("There was an error retrieving the value of from the allocation.")
                
                execution.executeWithDefault()
            }
        }
    }
    
    func executeAllWithValuesFromDefaults() {
        while !queue.isEmpty {
            guard let execution = queue.popLast() else {
                continue
            }
            
            execution.executeWithDefault()
        }
    }
    
}
