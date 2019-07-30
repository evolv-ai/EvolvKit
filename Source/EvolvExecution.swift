//
//  EvolvExecution.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

class EvolvExecution<T> {
    
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
        let optionalValue = try allocations.value(forKey: key, participant: participant)
        
        guard let value = optionalValue else {
            throw EvolvKeyError.errorMessage
        }
        
        guard let genericValue = value.rawValue as? T else {
            throw EvolvKeyError.mismatchTypes
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
