//
//  EvolvConfigTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
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
