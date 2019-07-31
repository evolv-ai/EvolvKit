//
//  CustomAllocationStore.swift
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

import EvolvKit

/// A custom in memory allocation store, this is a very basic example. One would likely use
/// sqlLite or an application storage implementation instead.
public class CustomAllocationStore: EvolvAllocationStore {
    
    private var allocations: [String: [EvolvRawAllocation]] = [:]
    
    public func get(_ participantId: String) -> [EvolvRawAllocation] {
        return allocations[participantId] ?? []
    }
    
    public func put(_ participantId: String, _ allocations: [EvolvRawAllocation]) {
        self.allocations.updateValue(allocations, forKey: participantId)
    }
    
}
