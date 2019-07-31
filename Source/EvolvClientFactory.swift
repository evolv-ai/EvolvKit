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
    public var client: EvolvClient
    public let logger = Log.logger
    
    public init(config: EvolvConfig) {
        logger.log(.debug, message: "Initializing Evolv Client.")
        let participant: EvolvParticipant = EvolvParticipant.builder().build()
        client = EvolvClientFactory.createClient(config: config, participant: participant)
    }
    
    /**
     Creates instances of the EvolvClient.
     - Parameters:
     - config: General configurations for the SDK.
     - participant: The participant for the initialized client.
     - Returns: an instance of EvolvClient
     */
    public init(config: EvolvConfig, participant: EvolvParticipant) {
        logger.log(.debug, message: "Initializing Evolv Client.")
        client = EvolvClientFactory.createClient(config: config, participant: participant)
    }
    
    private static func createClient(config: EvolvConfig, participant: EvolvParticipant) -> EvolvClient {
        let store = config.allocationStore
        let previousAllocations = store.get(participant.userId)
        let allocator: EvolvAllocator = EvolvAllocator(config: config, participant: participant)
        let futureAllocations = allocator.fetchAllocations()
        
        return DefaultEvolvClient(config: config,
                                  eventEmitter: EvolvEventEmitter(config: config, participant: participant),
                                  futureAllocations: futureAllocations,
                                  allocator: allocator,
                                  previousAllocations: !previousAllocations.isEmpty,
                                  participant: participant)
    }
    
}
