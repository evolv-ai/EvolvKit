//
//  EvolvClientHelper.swift
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
import EvolvKit

final class EvolvClientHelper {
    
    static let shared = EvolvClientHelper()
    
    private let environmentId: String = "sandbox"
    private let userId: String = "sandbox_user"
    
    private(set) var client: EvolvClient?
    private var httpClient: EvolvHttpClient
    private var store: EvolvAllocationStore
    
    var didChangeClientStatus: ((_ clientStatus: EvolvClientStatus) -> Void)?
    
    private init() {
        /*
         When you receive the fetched json from the participants API, it will be as type String.
         If you use the DefaultEvolvHttpClient, the string will be parsed to EvolvRawAllocation array
         (required data type for EvolvAllocationStore).
         
         This example shows how the data can be structured in your view controllers,
         your implementation can work directly with the raw string and serialize into EvolvRawAllocation.
         */
        store = CustomAllocationStore()
        httpClient = DefaultEvolvHttpClient()

        /// - Build config with custom timeout and custom allocation store
        // set client to use sandbox environment
        let config = EvolvConfig.builder(environmentId: environmentId, httpClient: httpClient)
            .set(allocationStore: store)
            .build()
        
        // set error or debug logLevel for debugging
        config.set(logLevel: .error)
        
        /// - Initialize the client with a stored user
        /// fetches allocations from Evolv, and stores them in a custom store
        client = EvolvClientFactory.createClient(config: config,
                                                 participant: EvolvParticipant.builder().set(userId: userId).build(),
                                                 delegate: self)
        
        /// - Initialize the client with a new user
        /// - Uncomment this line if you prefer this initialization.
        // client = EvolvClientFactory.createClient(config: config)
    }
    
}

extension EvolvClientHelper: EvolvClientDelegate {
    
    func didChangeClientStatus(_ status: EvolvClientStatus) {
        didChangeClientStatus?(status)
    }
    
}
