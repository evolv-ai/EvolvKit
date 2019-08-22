//
//  EvolvConfigTest.swift
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

import XCTest
import PromiseKit
@testable import EvolvKit

class EvolvConfigTest: XCTestCase {
    
    private let environmentId: String = "test_12345"
    private var mockHttpClient: EvolvHttpClient!
    
    override func setUp() {
        super.setUp()
        
        mockHttpClient = HttpClientMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockHttpClient = nil
    }
    
    func testBuildDefaultConfig() {
        let config = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        
        XCTAssertEqual(environmentId, config.environmentId)
        XCTAssertEqual(EvolvConfig.Default.httpScheme, config.httpScheme)
        XCTAssertEqual(EvolvConfig.Default.domain, config.domain)
        XCTAssertEqual(EvolvConfig.Default.apiVersion, config.version)
        XCTAssertNotNil(config.httpClient)
        XCTAssertNotNil(config.executionQueue)
    }
    
    func testBuildConfig() {
        let domain = "test.evolv.ai"
        let version = "test"
        let allocationStore = DefaultEvolvAllocationStore(size: 10)
        let httpScheme = "test"
        
        let config = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient)
            .set(domain: domain)
            .set(version: version)
            .set(allocationStore: allocationStore)
            .set(httpScheme: httpScheme)
            .build()
        
        XCTAssertEqual(environmentId, config.environmentId)
        XCTAssertEqual(domain, config.domain)
        XCTAssertEqual(version, config.version)
        XCTAssertNotNil(config.allocationStore)
        XCTAssertEqual(httpScheme, config.httpScheme)
    }
    
}
