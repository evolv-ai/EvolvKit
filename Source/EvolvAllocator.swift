//
//  EvolvAllocator.swift
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
    
    private lazy var jsonDecoder: JSONDecoder = JSONDecoder()
    
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
    
    func createAllocationsUrl() -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/allocations"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)")
        ]
        
        guard let url = components.url else {
            return URL(string: "")!
        }
        
        return url
    }
    
    func fetchAllocations() -> Promise<[EvolvRawAllocation]> {
        return Promise { [weak self] resolve in
            guard let self = self else {
                return
            }
            
            let url = self.createAllocationsUrl()
            
            _ = self.httpClient.get(url).done { (value) in
                guard let stringJSON = value as? String else {
                    return
                }
                
                var currentAllocations: [EvolvRawAllocation] = []
                
                do {
                    let jsonData = stringJSON.data(using: .utf8) ?? Data()
                    currentAllocations = try self.jsonDecoder.decode([EvolvRawAllocation].self, from: jsonData)
                } catch let error {
                    self.logger.error(error)
                }
                
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
                } catch let error {
                    _ = self.resolveAllocationsFailure()
                    self.logger.error("There was an error executing with allocations. \(error.localizedDescription)")
                }
            }
        }
    }
    
    func resolveAllocationsFailure() -> [EvolvRawAllocation] {
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
    
    static func allocationsNotEmpty(_ allocations: [EvolvRawAllocation]?) -> Bool {
        guard let allocations = allocations else {
            return false
        }
        
        return allocations.isEmpty == false
    }
    
}
