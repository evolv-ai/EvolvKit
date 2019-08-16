//
//  EvolvExecution.swift
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

protocol EvolvExecutable: AnyObject {
    func execute(with rawAllocations: [EvolvRawAllocation]) throws
    func executeWithDefault()
}

class EvolvExecution<T>: EvolvExecutable {
    
    enum Error: LocalizedError {
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
    
    func execute(with rawAllocations: [EvolvRawAllocation]) throws {
        let allocations = EvolvAllocations(rawAllocations)
        let node = try allocations.value(forKey: key)
        
        guard let genericValue = node.value as? T else {
            throw Error.mismatchTypes
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
