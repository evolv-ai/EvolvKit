//
//  EvolvClientFactory.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
public class EvolvClientFactory {
  private let LOGGER = Log.logger
  
  /**
   * Creates instances of the EvolvClient.
   *
   * @param config general configurations for the SDK
   * @return an instance of EvolvClient
   */
  
  public var client: EvolvClientProtocol
  
  init(config: EvolvConfig) {
    LOGGER.log(.debug, message: "Initializing Evolv Client.")
    let participant: EvolvParticipant = EvolvParticipant.builder().build()
    self.client = EvolvClientFactory.createClient(config: config, participant: participant)
  }
  
  /**
   * Creates instances of the EvolvClient.
   *
   * @param config general configurations for the SDK
   * @param participant the participant for the initialized client
   * @return an instance of EvolvClient
   */
  init(config: EvolvConfig, participant: EvolvParticipant) {
    LOGGER.log(.debug, message: "Initializing Evolv Client.")
    self.client = EvolvClientFactory.createClient(config: config, participant: participant)
  }
  
  private static func createClient(config: EvolvConfig, participant: EvolvParticipant) -> EvolvClientProtocol {
    let store = config.getEvolvAllocationStore()
    let previousAllocations = store.get(uid: participant.getUserId())
    let allocator: Allocator = Allocator(config: config, participant: participant)
    let futureAllocations = allocator.fetchAllocations()
    
    return EvolvClientImpl(config,
                           EventEmitter(config: config,participant: participant),
                           futureAllocations,
                           allocator,
                           Allocator.allocationsNotEmpty(allocations: previousAllocations),
                           participant)
  }
}
