//
//  EvolvAllocations.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

class EvolvAllocations {
    
    enum AllocationsError: LocalizedError, Equatable {
        case keyEmpty
        case genomeEmpty
        case valueNotFound(key: String)
        case incorrectKeyPart(key: String, keyPart: String)
        
        var errorDescription: String? {
            switch self {
            case .keyEmpty:
                return "Key provided was empty."
            case .genomeEmpty:
                return "Allocation genome was empty."
            case .valueNotFound(let key):
                return "No value was found in any allocations for key: \(key)"
            case .incorrectKeyPart(let key, let keyPart):
                return "Could not find element for keyPart: \(keyPart) in \(key)"
            }
        }
    }
    
    private let logger = EvolvLogger.shared
    
    private let rawAllocations: EvolvRawAllocations
    
    init(_ rawAllocations: EvolvRawAllocations) {
        self.rawAllocations = rawAllocations
    }
    
    // TODO: add audience filter logic
    func value(forKey key: String, participant: EvolvParticipant) throws -> JSON {
        let keyParts = key.components(separatedBy: ".").filter({ $0.isEmpty == false })

        if keyParts.isEmpty {
            throw AllocationsError.keyEmpty
        }
        
        for allocation in rawAllocations {
            let genome = allocation["genome"]
            
            do {
                let element = try getElement(fromGenome: genome, keyParts: keyParts)
                
                if element.error == nil {
                    return element
                }
            } catch let error {
                throw error
            }
        }
        
        throw AllocationsError.valueNotFound(key: key)
    }
    
    private func getElement(fromGenome genome: JSON, keyParts: [String]) throws -> JSON {
        var element: JSON = genome
        
        if element.isEmpty {
            throw AllocationsError.genomeEmpty
        }
        
        for part in keyParts {
            let object = element[part]
            
            if object.error != nil {
                let key = keyParts.joined(separator: ".")
                let error = AllocationsError.incorrectKeyPart(key: key, keyPart: part)
                logger.error(error)
                throw error
            }
            
            element = object
        }
        
        return element
    }
    
    static func reconcileAllocations(previousAllocations: EvolvRawAllocations,
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
    
    func getActiveExperiments() -> Set<String> {
        var activeExperiments = Set<String>()
        
        for allocation in rawAllocations {
            let eid = String(describing: allocation[EvolvRawAllocations.Key.experimentId.rawValue])
            activeExperiments.insert(eid)
        }
        
        return activeExperiments
    }
    
}
