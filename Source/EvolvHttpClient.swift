//
//  EvolvHttpClient.swift
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

import PromiseKit

@objc public protocol EvolvHttpClient {
    /// Performs a GET request to the **allocations endpoint** using the provided url.
    ///
    /// This call is asynchronous, the request is sent and a completable promise
    /// is returned. The promise is completed when the result of the request returns.
    ///
    /// - Parameter url: A valid url representing a call to the Participant API.
    /// - Returns: A response promise
    func get(_ url: URL) -> PromiseKit.AnyPromise
    
    /// Performs a GET request to the **events endpoint** using the provided url.
    ///
    /// This call is asynchronous, the request is sent and a completable future
    /// is returned. The future is completed when the result of the request returns.
    ///
    /// - Parameter url: A valid url representing a call to the Participant API.
    func sendEvents(_ url: URL)
}
