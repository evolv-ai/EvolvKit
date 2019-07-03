//
//  Allocator.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
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
  func sandbagConfirmation() -> () { confirmationSandbagged = true }
  func sandbagContamination() -> () { contaminationSandbagged = true }
  
  
  public func createAllocationsUrl() -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())")
    ]
    
    if let url = components.url { return url }
    return URL(string: "")!
  }
  
  public typealias JsonArray = [JSON]
  
  public func fetchAllocations() -> Promise<[JSON]> {
    
    return Promise { resolve in
      let url = self.createAllocationsUrl()
      
      let strPromise = self.httpClient.get(url: url).done { (stringJSON) in
        var allocations = JSON.init(parseJSON: stringJSON).arrayValue
        
        print("FETCHED FROM API: \(allocations)")
        let previous = self.store.get(uid: self.participant.getUserId())
        print("CACHED JSON: \(String(describing: previous))")
        if let prevAlloc = previous {
          if Allocator.allocationsNotEmpty(allocations: previous) {
            allocations = Allocations.reconcileAllocations(previousAllocations: prevAlloc, currentAllocations: allocations)
          }
        }
        
        self.store.set(uid: self.participant.getUserId(), allocations: allocations)
        let cachedAgain = self.store.get(uid: self.participant.getUserId())
        print("FETCHED JSON CACHED NOW: \(cachedAgain)")
        self.allocationStatus = AllocationStatus.RETRIEVED
        
        if (self.confirmationSandbagged) {
          self.eventEmitter.confirm(allocations: allocations)
        }
        
        if self.contaminationSandbagged {
          self.eventEmitter.contaminate(allocations: allocations)
        }
        resolve.fulfill(allocations)
        do {
          try self.executionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
        } catch let err {
          let message = "There was an error executing with allocations. \(err.localizedDescription)"
          self.LOGGER.log(.error, message: message)
        }
      }
    }
  }
  
  static func allocationsNotEmpty(allocations: [JSON]?) -> Bool {
    guard let allocArray = allocations else {
      return false
    }
    return allocArray.count > 0
  }
  
}

