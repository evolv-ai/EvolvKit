//
//  EvolvClientFactory.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

public class EvolvClientFactory {
  /**
   Creates instances of the EvolvClient.
   - Parameters:
   - config: General configurations for the SDK.
   - Returns:  an instance of EvolvClient
   */
  
  public var client: EvolvClientProtocol
  public let LOGGER = Log.logger
  
  public init(config: EvolvConfig) {
    LOGGER.log(.debug, message: "Initializing Evolv Client.")
    let participant: EvolvParticipant = EvolvParticipant.builder().build()
    self.client = EvolvClientFactory.createClient(config: config, participant: participant)
  }
  
  /**
   Creates instances of the EvolvClient.
   - Parameters:
       - config: General configurations for the SDK.
       - participant: The participant for the initialized client.
   - Returns: an instance of EvolvClient
   */
  
  public init(config: EvolvConfig, participant: EvolvParticipant) {
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
