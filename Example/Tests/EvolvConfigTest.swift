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
  
  private let ENVIRONMENT_ID = "test_12345"
  private var mockHttpClient: HttpProtocol!

    override func setUp() {
        self.mockHttpClient = HttpClientMock()
    }

    override func tearDown() {
      if let _ = self.mockHttpClient {
        self.mockHttpClient = nil
      }
    }

    func testBuildDefaultConfig() {
      let config = EvolvConfig.builder(environmentId: ENVIRONMENT_ID, httpClient: mockHttpClient).build()
      
      XCTAssertEqual(ENVIRONMENT_ID, config.getEnvironmentId())
      XCTAssertEqual(EvolvConfig.DEFAULT_HTTP_SCHEME, config.getHttpScheme())
      XCTAssertEqual(EvolvConfig.DEFAULT_DOMAIN, config.getDomain())
      XCTAssertEqual(EvolvConfig.DEFAULT_API_VERSION, config.getVersion())
      XCTAssertEqual(EvolvConfig.DEFAULT_HTTP_SCHEME, config.getHttpScheme())
      XCTAssertNotNil(config.getHttpClient)
      XCTAssertNotNil(config.getExecutionQueue())
    }

    func testBuildConfig() {
      let domain = "test.evolv.ai"
      let version = "test"
      let allocationStore = DefaultAllocationStore(size: 10)
      let httpScheme = "test"
      
      let config = EvolvConfig.builder(environmentId: ENVIRONMENT_ID, httpClient: mockHttpClient)
        .setDomain(domain: domain)
        .setVersion(version: version)
        .setEvolvAllocationStore(allocationStore: allocationStore)
        .setHttpScheme(scheme: httpScheme)
        .build()
      
      XCTAssertEqual(ENVIRONMENT_ID, config.getEnvironmentId())
      XCTAssertEqual(domain, config.getDomain())
      XCTAssertEqual(version, config.getVersion())
      XCTAssertNotNil(config.getEvolvAllocationStore())
      XCTAssertEqual(httpScheme, config.getHttpScheme())
    }
}
