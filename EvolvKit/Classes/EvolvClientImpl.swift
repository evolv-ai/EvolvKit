//
//  EvolvClientImpl.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON
import PromiseKit

public class EvolvClientImpl : EvolvClientProtocol {
  private let LOGGER = Log.logger
  
  private let eventEmitter: EventEmitter
  private let futureAllocations: Promise<[JSON]>?
  private let executionQueue: ExecutionQueue
  private let allocator: Allocator
  private let store: AllocationStoreProtocol
  private let previousAllocations: Bool
  private let participant: EvolvParticipant
  private let dispatchGroup = DispatchGroup()
  
  public init(_ config: EvolvConfig,
       _ eventEmitter: EventEmitter,
       _ futureAllocations: Promise<[JSON]>,
       _ allocator: Allocator,
       _ previousAllocations: Bool,
       _ participant: EvolvParticipant) {
    self.store = config.getEvolvAllocationStore()
    self.executionQueue = config.getExecutionQueue()
    self.eventEmitter = eventEmitter
    self.futureAllocations = futureAllocations
    self.allocator = allocator
    self.previousAllocations = previousAllocations
    self.participant = participant
  }
  
  fileprivate func getMyType<T>(_ element: T) -> Any? {
    return type(of: element)
  }
  
  public func get<T>(key: String, defaultValue: T) -> Any {
    var value = [JSON]()
    var promisedAllocations = [JSON]()
    
    if (futureAllocations == nil) {
      print("\(String(describing: futureAllocations))")
      return defaultValue
    }
    
    do {
      let a = try futureAllocations?.wait()
      guard let alloc = a else {
        return defaultValue
      }
      
      promisedAllocations = alloc
      if !Allocator.allocationsNotEmpty(allocations: promisedAllocations) {
        return defaultValue
      }
      
      let type = getMyType(defaultValue)
      guard let _ = type else { return defaultValue }
      do {
        let alloc = Allocations(allocations: promisedAllocations)
        let v = try alloc.getValueFromAllocations(key, type, participant)
        value = [v] as! [JSON]
      } catch {
        let message = "Unable to retrieve the treatment. Returning the default."
        LOGGER.log(.error, message: message)
        return defaultValue
      }
    } catch {
      LOGGER.log(.debug, message: "Error retrieving Allocations")
      return defaultValue
    }
    return value
  }
  
  public func subscribe<T>(key: String, defaultValue: T, function: @escaping (T) -> ()) {
    let execution = Execution(key, defaultValue, participant, function)
    let previous = self.store.get(uid: self.participant.getUserId())
    
    do {
      try execution.executeWithAllocation(rawAllocations: previous)
    } catch {
      let message = "Error from \(key). Error message: \(error.localizedDescription)."
      LOGGER.log(.error, message: message)
      execution.executeWithDefault()
    }

    
    let allocationStatus = allocator.getAllocationStatus()
    if allocationStatus == Allocator.AllocationStatus.FETCHING {
      executionQueue.enqueue(execution: execution)
      return
    } else if allocationStatus == Allocator.AllocationStatus.RETRIEVED {
      let allocations = store.get(uid: self.participant.getUserId())

      do {
        try execution.executeWithAllocation(rawAllocations: allocations)
        return
      } catch let err {
        let message = "Unable to retieve value from \(key), \(err.localizedDescription)"
        LOGGER.log(.error, message: message)
      }
    }
    execution.executeWithDefault()
  }
  
  public func emitEvent(key: String) -> Void {
    self.eventEmitter.emit(key)
  }
  
  public func emitEvent(key: String, score: Double) -> Void {
    self.eventEmitter.emit(key, score)
  }
  
  public func confirm() -> Void {
    let allocationStatus: Allocator.AllocationStatus = allocator.getAllocationStatus()
    if (allocationStatus == Allocator.AllocationStatus.FETCHING) {
      allocator.sandbagConfirmation()
    } else if (allocationStatus == Allocator.AllocationStatus.RETRIEVED) {
      let allocations = store.get(uid: participant.getUserId())
      eventEmitter.confirm(allocations: allocations)
    }
  }
  
  public func contaminate() -> Void {
    let allocationStatus: Allocator.AllocationStatus = allocator.getAllocationStatus()
    if (allocationStatus == Allocator.AllocationStatus.FETCHING) {
      allocator.sandbagContamination()
    } else if (allocationStatus == Allocator.AllocationStatus.RETRIEVED) {
      let allocations = store.get(uid: participant.getUserId())
      eventEmitter.contaminate(allocations: allocations)
    }
  }
  
}
