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
    private var mockHttpClient: HttpProtocol!

    override func setUp() {
        super.setUp()
        
        mockHttpClient = HttpClientMock()
    }

    override func tearDown() {
        super.tearDown()
        
      if self.mockHttpClient != nil {
        mockHttpClient = nil
      }
    }

    func testBuildDefaultConfig() {
      let config = EvolvConfig.builder(environmentId, mockHttpClient).build()
      
      XCTAssertEqual(environmentId, config.getEnvironmentId())
      XCTAssertEqual(EvolvConfig.Default.httpScheme, config.getHttpScheme())
      XCTAssertEqual(EvolvConfig.Default.domain, config.getDomain())
      XCTAssertEqual(EvolvConfig.Default.apiVersion, config.getVersion())
      XCTAssertNotNil(config.getHttpClient)
      XCTAssertNotNil(config.getExecutionQueue())
    }

    func testBuildConfig() {
      let domain = "test.evolv.ai"
      let version = "test"
      let allocationStore = DefaultAllocationStore(size: 10)
      let httpScheme = "test"
      
      let config = EvolvConfig.builder(environmentId, mockHttpClient)
        .setDomain(domain)
        .setVersion(version)
        .setEvolvAllocationStore(allocationStore)
        .setHttpScheme(scheme: httpScheme)
        .build()
      
      XCTAssertEqual(environmentId, config.getEnvironmentId())
      XCTAssertEqual(domain, config.getDomain())
      XCTAssertEqual(version, config.getVersion())
      XCTAssertNotNil(config.getEvolvAllocationStore())
      XCTAssertEqual(httpScheme, config.getHttpScheme())
    }
}
