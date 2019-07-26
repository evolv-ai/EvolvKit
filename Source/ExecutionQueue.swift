//
//  ExecutionQueue.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class ExecutionQueue {
  private let LOGGER = Log.logger
  private var queue = [Any]()
  public var count: Int!
  
  public init() {
    self.count = self.queue.count
  }
  
  static let shared = ExecutionQueue()
  
  public func enqueue<T>(_ execution: Execution<T>) {
    self.queue.insert(execution, at: 0)
    self.count += 1
  }
  
  public func executeAllWithValuesFromAllocations(_ allocations: [JSON]) throws {
    while !queue.isEmpty {
      var execution = queue.popLast() as Any
      do {
        if let executionString = execution as? Execution<String> {
          try executionString.executeWithAllocation(allocations)
          execution = executionString as Execution<String>
        } else if let executionInt = execution as? Execution<Int> {
          try executionInt.executeWithAllocation(allocations)
          execution = executionInt as Execution<Int>
        } else if let executionDbl = execution as? Execution<Double> {
          try executionDbl.executeWithAllocation(allocations)
          execution = executionDbl as Execution<Double>
        } else if let executionBool = execution as? Execution<Bool> {
          try executionBool.executeWithAllocation(allocations)
          execution = executionBool as Execution<Bool>
        } else if let executionFloat = execution as? Execution<Float> {
          try executionFloat.executeWithAllocation(allocations)
          execution = executionFloat as Execution<Float>
        } else {
          continue
        }
      } catch {
        let message = "There was an error retrieving the value of from the allocation."
        LOGGER.log(.debug, message: message)
        if let executionString = execution as? Execution<String> {
          executionString.executeWithDefault()
        } else if let executionInt = execution as? Execution<Int> {
          executionInt.executeWithDefault()
        } else if let executionDbl = execution as? Execution<Double> {
          executionDbl.executeWithDefault()
        } else if let executionBool = execution as? Execution<Bool> {
          executionBool.executeWithDefault()
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
        if let executionString = execution as? Execution<String> {
          executionString.executeWithDefault()
        } else if let executionInt = execution as? Execution<Int> {
          executionInt.executeWithDefault()
        } else if let executionDbl = execution as? Execution<Double> {
          executionDbl.executeWithDefault()
        } else if let executionBool = execution as? Execution<Bool> {
          executionBool.executeWithDefault()
        } else {
          continue
        }
        let message = "There was an error retrieving the value of from the allocation."
        LOGGER.log(.debug, message: message)
      }
    }
  }
}
