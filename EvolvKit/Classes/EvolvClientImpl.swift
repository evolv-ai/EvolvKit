//
//  EvolvClientImpl.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON
import PromiseKit

public class EvolvClientImpl: EvolvClientProtocol {
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
  
  public func subscribe<T>(_ key: String, _ defaultValue: T, _ function: @escaping (T) -> Void) {
    let execution = Execution(key, defaultValue, participant, function)
    let previousAllocations = self.store.get(self.participant.getUserId())
    
    do {
      try execution.executeWithAllocation(previousAllocations)
    } catch {
      let message = "Error from \(key). Error message: \(error.localizedDescription)."
      LOGGER.log(.error, message: message)
      execution.executeWithDefault()
    }

    let allocationStatus = allocator.getAllocationStatus()
    if allocationStatus == Allocator.AllocationStatus.FETCHING {
      executionQueue.enqueue(execution)
      return
    } else if allocationStatus == Allocator.AllocationStatus.RETRIEVED {
      let cachedAllocations = store.get(self.participant.getUserId())

      do {
        try execution.executeWithAllocation(cachedAllocations)
        return
      } catch let err {
        let message = "Unable to retieve value from \(key), \(err.localizedDescription)"
        LOGGER.log(.error, message: message)
      }
    }
    execution.executeWithDefault()
  }
  
  public func emitEvent(_ key: String) {
    self.eventEmitter.emit(key)
  }
  
  public func emitEvent(_ key: String, _ score: Double) {
    self.eventEmitter.emit(key, score)
  }
  
  public func confirm() {
    let allocationStatus: Allocator.AllocationStatus = allocator.getAllocationStatus()
    if allocationStatus == Allocator.AllocationStatus.FETCHING {
      allocator.sandbagConfirmation()
    } else if allocationStatus == Allocator.AllocationStatus.RETRIEVED {
      let allocations = store.get(participant.getUserId())
      eventEmitter.confirm(allocations)
    }
  }
  
  public func contaminate() {
    let allocationStatus: Allocator.AllocationStatus = allocator.getAllocationStatus()
    if allocationStatus == Allocator.AllocationStatus.FETCHING {
      allocator.sandbagContamination()
    } else if allocationStatus == Allocator.AllocationStatus.RETRIEVED {
      let allocations = store.get(participant.getUserId())
      eventEmitter.contaminate(allocations)
    }
  }
  
}
