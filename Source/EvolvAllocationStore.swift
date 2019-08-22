//
//  EvolvAllocationStore.swift
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

/// A type that can store and retrieve participant's allocations.
@objc public protocol EvolvAllocationStore {
    /// Retrieves a json converted to array of EvolvRawAllocation. Json represents the participant's allocations.
    /// If there are no stored allocations, should return an empty array.
    ///
    /// - Parameter participantId: The participant's unique id.
    /// - Returns: a EvolvRawAllocation array of allocation if one exists, else an empty array.
    func get(_ participantId: String) -> [EvolvRawAllocation]
    
    /// Stores an array of allocations.
    /// Stores the given EvolvRawAllocation array.
    ///
    /// - Parameters:
    ///   - participantId: The participant's unique id.
    ///   - rawAllocations: The participant's allocations.
    func put(_ participantId: String, _ rawAllocations: [EvolvRawAllocation])
}
