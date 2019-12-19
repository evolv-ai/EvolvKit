//
//  EvolvAllocations.swift
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

class EvolvAllocations {
    
    enum Error: LocalizedError, Equatable {
        case genomeEmpty
        case valueNotFound(key: String)
        
        var errorDescription: String? {
            switch self {
            case .genomeEmpty:
                return "Allocation genome was empty."
            case .valueNotFound(let key):
                return "No value was found in any allocations for key: \(key)"
            }
        }
    }
    
    private let logger = EvolvLogger.shared
    
    private let rawAllocations: [EvolvRawAllocation]
    private let store: EvolvAllocationStore
    
    init(_ rawAllocations: [EvolvRawAllocation], store: EvolvAllocationStore) {
        self.rawAllocations = rawAllocations
        self.store = store
    }
    
    func value(forKey key: String, participant: EvolvParticipant) throws -> EvolvRawAllocationNode {
        for allocation in rawAllocations {
            if allocation.isFilter(userAttributes: participant.userAttributes) {
                logger.debug("Participant was filtered from experiment \(allocation.experimentId)")
                continue
            }
            
            let genome = allocation.genome
            
            guard case .dictionary = genome.type else {
                throw Error.genomeEmpty
            }
            
            do {
                if let node = try genome.node(forKey: key) {
                    // touch current allocation & re-save allocations
                    allocation.state.insert(.touched)
                    
                    logger.debug("Found key '\(key)' with value '\(node.value)' from experiment \(allocation.experimentId).")
                    
                    // return node
                    return node
                }
            } catch {
                logger.debug("Unable to find key '\(key)' in experiment \(allocation.experimentId).")
            }
        }
        
        throw Error.valueNotFound(key: key)
    }
    
    func getActiveExperiments() -> Set<String> {
        return Set(rawAllocations.map({ $0.experimentId }))
    }
    
}

extension EvolvAllocations {
    
    static func reconcileAllocations(previousAllocations: [EvolvRawAllocation],
                                     currentAllocations: [EvolvRawAllocation]) -> [EvolvRawAllocation] {
        var allocations: [EvolvRawAllocation] = []
        
        for currentAllocation in currentAllocations {
            let currentEid = currentAllocation.experimentId
            var previousFound = false
            
            for previousAllocation in previousAllocations {
                let previousEid = previousAllocation.experimentId
                
                if currentEid.elementsEqual(previousEid) {
                    allocations.append(previousAllocation)
                    previousFound = true
                }
            }
            
            if !previousFound {
                allocations.append(currentAllocation)
            }
        }
        
        return allocations
    }
    
}
