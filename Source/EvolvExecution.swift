//
//  EvolvExecution.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

protocol EvolvExecutable: AnyObject {
    func execute(with rawAllocations: EvolvRawAllocations) throws
    func executeWithDefault()
}

class EvolvExecution<T>: EvolvExecutable {
    
    enum ExecutionError: LocalizedError {
        case mismatchTypes
        
        var errorDescription: String? {
            switch self {
            case .mismatchTypes:
                return "Mismatched Types"
            }
        }
    }
    
    let key: String
    private let participant: EvolvParticipant
    private var defaultValue: T
    private var alreadyExecuted: Set<String> = Set()
    private var closure: (T) -> Void
    
    init(key: String,
         defaultValue: T,
         participant: EvolvParticipant,
         closure: @escaping (T) -> Void) {
        self.key = key
        self.defaultValue = defaultValue
        self.participant = participant
        self.closure = closure
    }
    
    func execute(with rawAllocations: EvolvRawAllocations) throws {
        let allocations = EvolvAllocations(rawAllocations)
        let value = try allocations.value(forKey: key, participant: participant)
        
        guard let genericValue = value.rawValue as? T else {
            throw ExecutionError.mismatchTypes
        }
        
        let activeExperiements = allocations.getActiveExperiments()
        
        if alreadyExecuted.isEmpty || alreadyExecuted != activeExperiements {
            // there was a change to the allocations after reconciliation, apply changes
            closure(genericValue)
        }
        
        alreadyExecuted = activeExperiements
    }
    
    func executeWithDefault() {
        closure(defaultValue)
    }
    
}
