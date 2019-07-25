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

public typealias JsonArray = [JSON]?

public class Allocator {
  
  enum AllocationStatus {
    case FETCHING, RETRIEVED, FAILED
  }
  
  private let executionQueue: ExecutionQueue
  private let store: AllocationStoreProtocol
  private let config: EvolvConfig
  private let participant: EvolvParticipant
  private let eventEmitter: EventEmitter
  private let httpClient: HttpProtocol
  
  private var confirmationSandbagged: Bool = false
  private var contaminationSandbagged: Bool = false
  
  private var LOGGER = Log.logger
  private var allocationStatus: AllocationStatus
  
  init(config: EvolvConfig,
       participant: EvolvParticipant) {
    self.executionQueue = config.getExecutionQueue()
    self.store = config.getEvolvAllocationStore()
    self.config = config
    self.participant = participant
    self.httpClient = config.getHttpClient()
    self.allocationStatus = AllocationStatus.FETCHING
    self.eventEmitter = EventEmitter(config: config, participant: participant)
  }
  
  func getAllocationStatus() -> AllocationStatus { return allocationStatus }
  func sandbagConfirmation() { confirmationSandbagged = true }
  func sandbagContamination() { contaminationSandbagged = true }
  
  public func createAllocationsUrl() -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    return url
  }
  
  public typealias JsonArray = [JSON]
  
  public func fetchAllocations() -> Promise<[JSON]> {
    
    return Promise { resolve in
      let url = self.createAllocationsUrl()
      
      _ = self.httpClient.get(url: url).done { (stringJSON) in
        var allocations = JSON.init(parseJSON: stringJSON).arrayValue
        let previous = self.store.get(uid: self.participant.getUserId())
        
        if Allocator.allocationsNotEmpty(allocations: previous) {
          allocations = Allocations.reconcileAllocations(previousAllocations: previous,
                                                         currentAllocations: allocations)
        }
        
        self.store.put(uid: self.participant.getUserId(), allocations: allocations)
        self.allocationStatus = AllocationStatus.RETRIEVED
        
        if self.confirmationSandbagged {
          self.eventEmitter.confirm(allocations: allocations)
        }
        
        if self.contaminationSandbagged {
          self.eventEmitter.contaminate(allocations: allocations)
        }
        resolve.fulfill(allocations)
        do {
          try self.executionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
        } catch let err {
          _ = self.resolveAllocationsFailure()
          let message = "There was an error executing with allocations. \(err.localizedDescription)"
          self.LOGGER.log(.error, message: message)
        }
      }
    }
  }
  
  public func resolveAllocationsFailure() -> [JSON] {
    let previous = self.store.get(uid: self.participant.getUserId())
    
    if Allocator.allocationsNotEmpty(allocations: previous) {
      LOGGER.log(.debug, message: "Falling back to participant's previous allocation.")
      
      if confirmationSandbagged {
        eventEmitter.confirm(allocations: previous)
      }
      if contaminationSandbagged {
        eventEmitter.contaminate(allocations: previous)
      }
      
      allocationStatus = AllocationStatus.RETRIEVED
      do {
        try executionQueue.executeAllWithValuesFromAllocations(allocations: previous)
      } catch {
        LOGGER.log(.error, message: "Execution with values from Allocations fails, falling back on defaults.")
        executionQueue.executeAllWithValuesFromDefaults()
        return previous
      }
      
    } else {
      LOGGER.log(.error, message: "Falling back to the supplied defaults.")
      allocationStatus = AllocationStatus.FAILED
      executionQueue.executeAllWithValuesFromDefaults()
      return previous
    }
  
    return previous
  }
  
  static func allocationsNotEmpty(allocations: [JSON]?) -> Bool {
    guard let allocArray = allocations else {
      return false
    }
    return allocArray.isEmpty == false
  }
}
