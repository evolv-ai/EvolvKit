//
//  DefaultEvolvClient.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PromiseKit

/// The statuses that indicate whether a client can successfully use
@objc public enum EvolvClientStatus: Int {
    case unknown
    case initializing
    case ready
}

@objc public protocol EvolvClientDelegate: AnyObject {
    func didChangeClientStatus(_ status: EvolvClientStatus)
}

class DefaultEvolvClient: EvolvClient {
    
    private let logger = EvolvLogger.shared
    
    private let eventEmitter: EvolvEventEmitter
    private let futureAllocations: Promise<[EvolvRawAllocation]>?
    private let executionQueue: EvolvExecutionQueue
    private let allocator: EvolvAllocator
    private let store: EvolvAllocationStore
    private let previousAllocations: Bool
    private let participant: EvolvParticipant
    
    // status
    private(set) var status: EvolvClientStatus = .unknown {
        didSet {
            delegate?.didChangeClientStatus(status)
            
            switch status {
            case .initializing:
                logger.debug("Evolv Client - Initializing.")
            case .ready:
                logger.debug("Evolv Client - Ready for use.")
            default:
                break
            }
        }
    }
    public weak var delegate: EvolvClientDelegate?
    
    init(config: EvolvConfig,
         eventEmitter: EvolvEventEmitter,
         futureAllocations: Promise<[EvolvRawAllocation]>,
         allocator: EvolvAllocator,
         previousAllocations: Bool,
         participant: EvolvParticipant) {
        defer {
            status = .initializing
        }
        
        self.store = config.allocationStore
        self.executionQueue = config.executionQueue
        self.eventEmitter = eventEmitter
        self.futureAllocations = futureAllocations
        self.allocator = allocator
        self.previousAllocations = previousAllocations
        self.participant = participant
    }
    
    public func subscribe(forKey key: String,
                          defaultValue: EvolvRawAllocationNode,
                          closure: @escaping (EvolvRawAllocationNode) -> Void) {
        let execution = EvolvExecution(key: key,
                                       defaultValue: defaultValue,
                                       participant: participant,
                                       store: store,
                                       closure: closure)
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

// MARK: - EvolvAllocatorDelegate

extension DefaultEvolvClient: EvolvAllocatorDelegate {
    
    func didChangeAllocationStatus(_ allocationStatus: EvolvAllocator.AllocationStatus) {
        switch allocationStatus {
        case .retrieved, .failed:
            status = .ready
        default:
            break
        }
    }
    
}
