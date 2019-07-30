//
//  EvolvExecutionQueue.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

class EvolvExecutionQueue {
    
    private let logger = Log.logger
    private var queue: [Any] = []
    public var count: Int = 0
    
    init() {}
    
    static let shared = EvolvExecutionQueue()
    
    public func enqueue<T>(_ execution: EvolvExecution<T>) {
        queue.insert(execution, at: 0)
        count += 1
    }
    
    public func executeAllWithValues(from rawAllocations: EvolvRawAllocations) throws {
        while !queue.isEmpty {
            var execution = queue.popLast() as Any
            
            do {
                if let executionString = execution as? EvolvExecution<String> {
                    try executionString.execute(with: rawAllocations)
                    execution = executionString as EvolvExecution<String>
                } else if let executionInt = execution as? EvolvExecution<Int> {
                    try executionInt.execute(with: rawAllocations)
                    execution = executionInt as EvolvExecution<Int>
                } else if let executionDouble = execution as? EvolvExecution<Double> {
                    try executionDouble.execute(with: rawAllocations)
                    execution = executionDouble as EvolvExecution<Double>
                } else if let executionBool = execution as? EvolvExecution<Bool> {
                    try executionBool.execute(with: rawAllocations)
                    execution = executionBool as EvolvExecution<Bool>
                } else if let executionFloat = execution as? EvolvExecution<Float> {
                    try executionFloat.execute(with: rawAllocations)
                    execution = executionFloat as EvolvExecution<Float>
                } else {
                    continue
                }
            } catch {
                let message = "There was an error retrieving the value of from the allocation."
                logger.log(.debug, message: message)
                
                if let executionString = execution as? EvolvExecution<String> {
                    executionString.executeWithDefault()
                } else if let executionInt = execution as? EvolvExecution<Int> {
                    executionInt.executeWithDefault()
                } else if let executionDouble = execution as? EvolvExecution<Double> {
                    executionDouble.executeWithDefault()
                } else if let executionBool = execution as? EvolvExecution<Bool> {
                    executionBool.executeWithDefault()
                } else if let executionFloat = execution as? EvolvExecution<Float> {
                    executionFloat.executeWithDefault()
                } else {
                    continue
                }
            }
        }
    }
    
    func executeAllWithValuesFromDefaults() {
        while !queue.isEmpty {
            let execution = queue.popLast() as Any
            
            do {
                if let executionString = execution as? EvolvExecution<String> {
                    executionString.executeWithDefault()
                } else if let executionInt = execution as? EvolvExecution<Int> {
                    executionInt.executeWithDefault()
                } else if let executionDouble = execution as? EvolvExecution<Double> {
                    executionDouble.executeWithDefault()
                } else if let executionBool = execution as? EvolvExecution<Bool> {
                    executionBool.executeWithDefault()
                } else if let executionFloat = execution as? EvolvExecution<Float> {
                    executionFloat.executeWithDefault()
                } else {
                    continue
                }
                
                let message = "There was an error retrieving the value of from the allocation."
                logger.log(.debug, message: message)
            }
        }
    }
    
}
