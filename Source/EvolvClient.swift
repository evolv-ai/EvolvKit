//
//  EvolvClient.swift
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

@objc public protocol EvolvClient {
    /// Retrieves a value from Evolv asynchronously and applies some custom action.
    ///
    /// This method is non blocking. It will preform the programmed action once
    /// the allocation is available. If there is already of stored allocation
    /// it will immediately apply the value retrieved and then when the new
    /// allocation returns it will reapply the new changes if the experiment
    /// has changed.
    ///
    /// - Parameters:
    ///   - key: A unique key identifying a specific value in the participants allocation.
    ///   - defaultValue: A default value to return upon error.
    ///   - closure: a handler that is invoked when the allocation is updated
    ///     - <T>: type of value to be applied to the execution.
    func subscribe(forKey key: String,
                   defaultValue: EvolvRawAllocationNode,
                   closure: @escaping (EvolvRawAllocationNode) -> Void)
    
    /// Emits a generic event to be recorded by Evolv.
    ///
    /// Sends an event to Evolv to be recorded and reported upon. Also records
    /// a generic score value to be associated with the event.
    ///
    /// - Parameters:
    ///   - key: The identifier of the event.
    ///   - score: A score to be associated with the event.
    @objc func emitEvent(forKey key: String, score: Double)
    
    /// Emits a generic event to be recorded by Evolv.
    ///
    /// Sends an event to Evolv to be recorded and reported upon.
    ///
    /// - Parameter key: The identifier of the event.
    @objc func emitEvent(forKey key: String)
    
    /// Sends a confirmed event to Evolv.
    ///
    /// Method produces a confirmed event which confirms the participant's
    /// allocation. Method will not do anything in the event that the allocation
    /// timed out or failed.
    @objc func confirm()
    
    /// Sends a contamination event to Evolv.
    ///
    ///  Method produces a contamination event which will contaminate the
    /// participant's allocation. Method will not do anything in the event
    /// that the allocation timed out or failed.
    @objc func contaminate()
}
