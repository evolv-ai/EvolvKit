//
//  EvolvAllocations.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

class EvolvAllocations {
    
    let rawAllocations: EvolvRawAllocations
    let audience: EvolvAudience = EvolvAudience()
    private let logger = Log.logger
    
    init(_ rawAllocations: EvolvRawAllocations) {
        self.rawAllocations = rawAllocations
    }
    
    // TODO: add audience filter logic
    public func value(forKey key: String, participant: EvolvParticipant) throws -> JSON? {
        let keyParts = key.components(separatedBy: ".")
        
        if keyParts.isEmpty {
            throw EvolvKeyError(rawValue: "Key provided was empty.")!
        }
        
        for allocation in rawAllocations {
            let genome = allocation["genome"]
            let element = try getElement(fromGenome: genome, keyParts: keyParts)
            
            if element.error == nil {
                return element
            } else {
                throw EvolvKeyError.errorMessage
            }
        }
        
        let errorJson = JSON([key: "Unable to find key in experiment"])
        return errorJson
    }
    
    private func getElement(fromGenome genome: JSON, keyParts: [String]) throws -> JSON {
        var element: JSON = genome
        
        if element.isEmpty {
            throw EvolvKeyError.genomeEmpty
        }
        
        for part in keyParts {
            let object = element[part]
            element = object
            
            if element.error != nil {
                throw EvolvKeyError.elementFails
                logger.log(.error, message: "Element fails")
            }
        }
        
        return element
    }
    
    static public func reconcileAllocations(previousAllocations: EvolvRawAllocations,
                                            currentAllocations: EvolvRawAllocations) -> EvolvRawAllocations {
        var allocations: EvolvRawAllocations = []
        
        for currentAllocation in currentAllocations {
            let currentEid = String(describing: currentAllocation[EvolvRawAllocations.Key.experimentId.rawValue])
            var previousFound = false
            
            for previousAllocation in previousAllocations {
                let previousEid = String(describing: previousAllocation[EvolvRawAllocations.Key.experimentId.rawValue])
                
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
    
    public func getActiveExperiments() -> Set<String> {
        var activeExperiments = Set<String>()
        
        for allocation in rawAllocations {
            let eid = String(describing: allocation[EvolvRawAllocations.Key.experimentId.rawValue])
            activeExperiments.insert(eid)
        }
        
        return activeExperiments
    }
    
}
