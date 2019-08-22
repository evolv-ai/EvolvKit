//
//  EvolvClientFactory.swift
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

import Foundation

public class EvolvClientFactory: NSObject {
    
    /// Creates instances of the EvolvClient.
    ///
    /// - Parameters:
    ///   - config: General configurations for the SDK.
    ///   - participant: The participant for the initialized client.
    /// - Returns: an instance of EvolvClient
    @objc public class func createClient(config: EvolvConfig, participant: EvolvParticipant? = nil) -> EvolvClient {
        EvolvLogger.shared.debug("Initializing Evolv Client.")
        
        let participant = participant ?? EvolvParticipant.builder().build()
        let store = config.allocationStore
        let previousAllocations = store.get(participant.userId)
        let allocator = EvolvAllocator(config: config, participant: participant)
        let futureAllocations = allocator.fetchAllocations()
        let eventEmitter = EvolvEventEmitter(config: config, participant: participant)
        
        defer {
            EvolvLogger.shared.debug("Initialized Evolv Client.")
        }
        
        return DefaultEvolvClient(config: config,
                                  eventEmitter: eventEmitter,
                                  futureAllocations: futureAllocations,
                                  allocator: allocator,
                                  previousAllocations: !previousAllocations.isEmpty,
                                  participant: participant)
    }
    
}
