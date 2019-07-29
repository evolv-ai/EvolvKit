//
//  Allocations.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class Allocations {
    
    let allocations: [JSON]
    let audience: Audience = Audience()
    let LOGGER = Log.logger
    
    public init (_ allocations: [JSON]) {
        self.allocations = allocations
    }
    
    func getMyType<T>(_ element: T) -> Any? {
        return type(of: element)
    }
    
    public func getValueFromAllocations<T>(_ key: String, _ type: T, _ participant: EvolvParticipant) throws -> JSON? {
        let keyParts = key.components(separatedBy: ".")
        
        if keyParts.isEmpty {
            throw EvolvKeyError(rawValue: "Key provided was empty.")!
        }
        
        for allocation in self.allocations {
            let genome = allocation["genome"]
            let element = try getElementFromGenome(genome, keyParts)
            
            if element.error == nil {
                return element
            } else {
                throw EvolvKeyError.errorMessage
            }
        }
        
        let errorJson = JSON([key: "Unable to find key in experiment"])
        return errorJson
    }
    
    private func getElementFromGenome(_ genome: JSON, _ keyParts: [String]) throws -> JSON {
        var element: JSON = genome
        
        if element.isEmpty {
            throw EvolvKeyError.genomeEmpty
        }
        
        for part in keyParts {
            let object = element[part]
            element = object
            
            if element.error != nil {
                throw EvolvKeyError.elementFails
                LOGGER.log(.error, message: "Element fails")
            }
        }
        
        return element
    }
    
    static public func reconcileAllocations(_ previousAllocations: [JSON], _ currentAllocations: [JSON]) -> [JSON] {
        var allocations = [JSON]()
        
        for currentAllocation in currentAllocations {
            let currentEid = String(describing: currentAllocation["eid"])
            var previousFound = false
            
            for previousAllocation in previousAllocations {
                let previousEid = String(describing: previousAllocation["eid"])
                
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
        
        for allocation in allocations {
            let eid = String(describing: allocation["eid"])
            activeExperiments.insert(eid)
        }
        
        return activeExperiments
    }
    
}
