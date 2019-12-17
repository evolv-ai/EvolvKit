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
    
    static var shared: EvolvClientHelper = {
        let helper = EvolvClientHelper()
        _ = helper.client
        return helper
    }()
    
    lazy var client: EvolvClient = {
        /// When you receive the fetched json from the participants API, it will be as type String.
        /// If you use the DefaultEvolvHttpClient, the string will be parsed to EvolvRawAllocation array
        /// (required data type for EvolvAllocationStore).
        let store: EvolvAllocationStore = CustomAllocationStore()
        let httpClient: EvolvHttpClient = DefaultEvolvHttpClient()
        
        /// Build config with custom timeout and custom allocation store.
        /// Set client to any one of your environmentIds. sandbox is an example id.
        let config = EvolvConfig.builder(environmentId: "a0cf1cfaab", httpClient: httpClient)
            .set(allocationStore: store)
            .build()
        
        /// set error or debug logLevel for debugging
        config.set(logLevel: .error)
        
        /// Initialize the client with a stored user
        /// fetches allocations from Evolv, and stores them in a custom store
        let client = EvolvClientFactory.createClient(config: config,
                                                     participant: EvolvParticipant.builder().set(userId: "example_user").build(),
                                                     delegate: self)
        
        /// Initialize the client with a new user
        /// Uncomment this line if you prefer this initialization.
        // let client = EvolvClientFactory.createClient(config: config)
        
        return client
    }()
    
    var didChangeClientStatus: ((_ clientStatus: EvolvClientStatus) -> Void)?
    
    private init() {}
    
}

extension EvolvClientHelper: EvolvClientDelegate {
    
    func didChangeClientStatus(_ status: EvolvClientStatus) {
        didChangeClientStatus?(status)
    }
    
}
