//
//  Allocator.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Alamofire
import SwiftyJSON
import PromiseKit

public class Allocator {
    
    public enum AllocationStatus {
        case fetching
        case retrieved
        case failed
    }
    
    private let config: EvolvConfig
    private let eventEmitter: EventEmitter
    private let executionQueue: ExecutionQueue
    private let httpClient: HttpProtocol
    private let participant: EvolvParticipant
    private let store: AllocationStoreProtocol
    
    private var confirmationSandbagged: Bool = false
    private var contaminationSandbagged: Bool = false
    
    private var LOGGER = Log.logger
    private var allocationStatus: AllocationStatus
    
    public init(_ config: EvolvConfig,
                _ participant: EvolvParticipant) {
        self.executionQueue = config.getExecutionQueue()
        self.store = config.getEvolvAllocationStore()
        self.config = config
        self.participant = participant
        self.httpClient = config.getHttpClient()
        self.allocationStatus = .fetching
        self.eventEmitter = EventEmitter(config, participant)
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
    
    private func createUrlComponents(_ config: EvolvConfig) -> URLComponents {
        var components = URLComponents()
        components.scheme = config.getHttpScheme()
        components.host = config.getDomain()
        return components
    }
    
    public func createAllocationsUrl() -> URL {
        var components = createUrlComponents(config)
        components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
        components.queryItems = [
            URLQueryItem(name: "uid", value: "\(participant.getUserId())")
        ]
        
        guard let url = components.url else {
            return URL(string: "")!
        }
        
        return url
    }
    
    public func fetchAllocations() -> Promise<[JSON]> {
        return Promise { resolve in
            let url = self.createAllocationsUrl()
            
            _ = self.httpClient.get(url).done { (stringJSON) in
                var currentAllocations = JSON.init(parseJSON: stringJSON).arrayValue
                let previousAllocations = self.store.get(self.participant.getUserId())
                
                if Allocator.allocationsNotEmpty(previousAllocations) {
                    currentAllocations = Allocations.reconcileAllocations(previousAllocations, currentAllocations)
                }
                
                self.store.put(self.participant.getUserId(), currentAllocations)
                self.allocationStatus = .retrieved
                
                if self.confirmationSandbagged {
                    self.eventEmitter.confirm(currentAllocations)
                }
                
                if self.contaminationSandbagged {
                    self.eventEmitter.contaminate(currentAllocations)
                }
                
                resolve.fulfill(currentAllocations)
                
                do {
                    try self.executionQueue.executeAllWithValuesFromAllocations(currentAllocations)
                } catch let err {
                    _ = self.resolveAllocationsFailure()
                    let message = "There was an error executing with allocations. \(err.localizedDescription)"
                    self.LOGGER.log(.error, message: message)
                }
            }
        }
    }
    
    public func resolveAllocationsFailure() -> [JSON] {
        let previousAllocations = self.store.get(self.participant.getUserId())
        
        if Allocator.allocationsNotEmpty(previousAllocations) {
            LOGGER.log(.debug, message: "Falling back to participant's previous allocation.")
            
            if confirmationSandbagged {
                eventEmitter.confirm(previousAllocations)
            }
            if contaminationSandbagged {
                eventEmitter.contaminate(previousAllocations)
            }
            
            allocationStatus = .retrieved
            
            do {
                try executionQueue.executeAllWithValuesFromAllocations(previousAllocations)
            } catch {
                LOGGER.log(.error, message: "Execution with values from Allocations fails, falling back on defaults.")
                executionQueue.executeAllWithValuesFromDefaults()
                return previousAllocations
            }
        } else {
            LOGGER.log(.error, message: "Falling back to the supplied defaults.")
            allocationStatus = .failed
            executionQueue.executeAllWithValuesFromDefaults()
            return previousAllocations
        }
        
        return previousAllocations
    }
    
    public static func allocationsNotEmpty(_ allocations: [JSON]?) -> Bool {
        guard let allocArray = allocations else {
            return false
        }
        
        return allocArray.isEmpty == false
    }
    
}
