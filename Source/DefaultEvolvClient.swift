//
//  DefaultEvolvClient.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON
import PromiseKit

class DefaultEvolvClient: EvolvClient {
    
    private let logger = EvolvLogger.shared
    
    private let eventEmitter: EvolvEventEmitter
    private let futureAllocations: Promise<EvolvRawAllocations>?
    private let executionQueue: EvolvExecutionQueue
    private let allocator: EvolvAllocator
    private let store: EvolvAllocationStore
    private let previousAllocations: Bool
    private let participant: EvolvParticipant
    
    init(config: EvolvConfig,
         eventEmitter: EvolvEventEmitter,
         futureAllocations: Promise<EvolvRawAllocations>,
         allocator: EvolvAllocator,
         previousAllocations: Bool,
         participant: EvolvParticipant) {
        self.store = config.allocationStore
        self.executionQueue = config.executionQueue
        self.eventEmitter = eventEmitter
        self.futureAllocations = futureAllocations
        self.allocator = allocator
        self.previousAllocations = previousAllocations
        self.participant = participant
    }
    
    public func subscribe<T>(forKey key: String, defaultValue: T, closure: @escaping (T) -> Void) {
        let execution = EvolvExecution(key: key, defaultValue: defaultValue, participant: participant, closure: closure)
        let previousAllocations = store.get(participant.userId)
        
        if previousAllocations.isEmpty == false {
            do {
                try execution.execute(with: previousAllocations)
            } catch {
                logger.error("Error from \(key). Error message: \(error.localizedDescription).")
                execution.executeWithDefault()
            }
        }
        
        let allocationStatus = allocator.getAllocationStatus()
        
        switch allocationStatus {
        case .fetching:
            executionQueue.enqueue(execution)
        case .retrieved:
            let cachedAllocations = store.get(participant.userId)
            
            do {
                try execution.execute(with: cachedAllocations)
            } catch let error {
                logger.error("Unable to retieve value from \(key), \(error.localizedDescription)")
            }
        default:
            execution.executeWithDefault()
        }
    }
    
    public func emitEvent(forKey key: String) {
        eventEmitter.emit(forKey: key)
    }
    
    public func emitEvent(forKey key: String, score: Double) {
        eventEmitter.emit(forKey: key, score: score)
    }
    
    public func confirm() {
        let allocationStatus: EvolvAllocator.AllocationStatus = allocator.getAllocationStatus()
        
        if allocationStatus == .fetching {
            allocator.sandbagConfirmation()
        } else if allocationStatus == .retrieved {
            let allocations = store.get(participant.userId)
            eventEmitter.confirm(rawAllocations: allocations)
        }
    }
    
    public func contaminate() {
        let allocationStatus: EvolvAllocator.AllocationStatus = allocator.getAllocationStatus()
        
        if allocationStatus == .fetching {
            allocator.sandbagContamination()
        } else if allocationStatus == .retrieved {
            let allocations = store.get(participant.userId)
            eventEmitter.contaminate(rawAllocations: allocations)
        }
    }
    
}
