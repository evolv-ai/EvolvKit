//
//  EvolvAllocator.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Alamofire
import SwiftyJSON
import PromiseKit

class EvolvAllocator {
    
    public enum AllocationStatus {
        case fetching
        case retrieved
        case failed
    }
    
    private let logger = EvolvLogger.shared
    
    private let config: EvolvConfig
    private let eventEmitter: EvolvEventEmitter
    private let executionQueue: EvolvExecutionQueue
    private let httpClient: EvolvHttpClient
    private let participant: EvolvParticipant
    private let store: EvolvAllocationStore
    
    private var confirmationSandbagged: Bool = false
    private var contaminationSandbagged: Bool = false
    private var allocationStatus: AllocationStatus
    
    init(config: EvolvConfig, participant: EvolvParticipant) {
        self.executionQueue = config.executionQueue
        self.store = config.allocationStore
        self.config = config
        self.participant = participant
        self.httpClient = config.httpClient
        self.allocationStatus = .fetching
        self.eventEmitter = EvolvEventEmitter(config: config, participant: participant)
    }
    
    func getAllocationStatus() -> AllocationStatus {
        return allocationStatus
    }
    
    func sandbagConfirmation() {
        confirmationSandbagged = true
    }
    
    func sandbagContamination() {
        contaminationSandbagged = true
    }
    
    private func createUrlComponents(config: EvolvConfig) -> URLComponents {
        var components = URLComponents()
        components.scheme = config.httpScheme
        components.host = config.domain
        return components
    }
    
    public func createAllocationsUrl() -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/allocations"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocations.Key.userId.rawValue, value: "\(participant.userId)")
        ]
        
        guard let url = components.url else {
            return URL(string: "")!
        }
        
        return url
    }
    
    func fetchAllocations() -> Promise<EvolvRawAllocations> {
        return Promise { resolve in
            let url = self.createAllocationsUrl()
            
            _ = self.httpClient.get(url).done { (stringJSON) in
                var currentAllocations = JSON(parseJSON: stringJSON).arrayValue
                let previousAllocations = self.store.get(self.participant.userId)
                
                if previousAllocations.isEmpty == false {
                    currentAllocations = EvolvAllocations.reconcileAllocations(previousAllocations: previousAllocations,
                                                                               currentAllocations: currentAllocations)
                }
                
                self.store.put(self.participant.userId, currentAllocations)
                self.allocationStatus = .retrieved
                
                if self.confirmationSandbagged {
                    self.eventEmitter.confirm(rawAllocations: currentAllocations)
                }
                
                if self.contaminationSandbagged {
                    self.eventEmitter.contaminate(rawAllocations: currentAllocations)
                }
                
                resolve.fulfill(currentAllocations)
                
                do {
                    try self.executionQueue.executeAllWithValues(from: currentAllocations)
                } catch let err {
                    _ = self.resolveAllocationsFailure()
                    self.logger.error("There was an error executing with allocations. \(err.localizedDescription)")
                }
            }
        }
    }
    
    func resolveAllocationsFailure() -> EvolvRawAllocations {
        let previousAllocations = store.get(participant.userId)
        
        if previousAllocations.isEmpty == false {
            logger.debug("Falling back to participant's previous allocation.")
            
            if confirmationSandbagged {
                eventEmitter.confirm(rawAllocations: previousAllocations)
            }
            
            if contaminationSandbagged {
                eventEmitter.contaminate(rawAllocations: previousAllocations)
            }
            
            allocationStatus = .retrieved
            
            do {
                try executionQueue.executeAllWithValues(from: previousAllocations)
            } catch {
                logger.error("Execution with values from Allocations fails, falling back on defaults.")
                
                executionQueue.executeAllWithValuesFromDefaults()
                return previousAllocations
            }
        } else {
            logger.error("Falling back to the supplied defaults.")
            
            allocationStatus = .failed
            executionQueue.executeAllWithValuesFromDefaults()
            return previousAllocations
        }
        
        return previousAllocations
    }
    
    static func allocationsNotEmpty(_ allocations: EvolvRawAllocations?) -> Bool {
        guard let allocations = allocations else {
            return false
        }
        
        return allocations.isEmpty == false
    }
    
}
