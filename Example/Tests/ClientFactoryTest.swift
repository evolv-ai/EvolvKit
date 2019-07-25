//
//  EvolvClientTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class ClientFactoryTest: XCTestCase {
  
  private let environmentId: String = "test_12345"
    private var rawAllocations: [JSON] {
        let data: [[String: Any]] = [
            [
                "uid": "test_uid",
                "sid": "test_sid",
                "eid": "test_eid",
                "cid": "test_cid",
                "genome": [
                    "search": [
                        "weighting": [
                            "distance": 2.5,
                            "dealer_score": 2.5
                        ]
                    ],
                    "pages": [
                        "all_pages": [
                            "header_footer": [
                                "blue",
                                "white"
                            ]
                        ],
                        "testing_page": [
                            "megatron": "none",
                            "header": "white"
                        ]
                    ],
                    "algorithms": [
                        "feature_importance": false
                    ]
                ],
                "excluded": false
            ]
        ]
        
        return JSON(data).arrayValue
    }
    private var rawAllocationString: String {
        return "[\(rawAllocations.compactMap({ $0.rawString() }).joined(separator: ","))]"
    }

  private var mockHttpClient: HttpProtocol!
  private var mockAllocationStore: AllocationStoreProtocol!
  private var mockExecutionQueue: ExecutionQueue!
  private var mockConfig: EvolvConfig!
  
    override func setUp() {
        super.setUp()
        
      mockHttpClient = HttpClientMock()
      mockAllocationStore = AllocationStoreMock(testCase: self)
      mockExecutionQueue = ExecutionQueueMock()
      mockConfig = ConfigMock("https", "test_domain", "test_v", "test_eid", mockAllocationStore, mockHttpClient)
    }

    override func tearDown() {
        super.tearDown()
        
      if mockHttpClient != nil {
        mockHttpClient = nil
      }
      if mockAllocationStore != nil {
        mockAllocationStore = nil
      }
      if mockExecutionQueue != nil {
        mockExecutionQueue = nil
      }
      if mockConfig != nil {
        mockConfig = nil
      }
    }

  func createAllocationsUrl(config: EvolvConfig, participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())")
    ]
    return components.url!
  }

  func testClientInit() {
    let actualConfig = EvolvConfig.builder(environmentId,
                                           mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    var responsePromise = mockHttpClient.get(url: URL(string: anyString(length: 12))!)
    responsePromise = Promise { resolver in
        resolver.fulfill(rawAllocationString)
    }
    
    XCTAssertNotNil(responsePromise)
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    
    let client = EvolvClientFactory(config: mockConfig)
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    XCTAssertNotNil(client)
  }

  fileprivate func anyString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
  
  func testClientInitSameUser() {
    let participant = EvolvParticipant.builder().setUserId(userId: "test_uid").build()
    let mockClient = HttpClientMock()
    
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockConfig, actualConfig,
                                                                             mockExecutionQueue, mockClient, mockAllocationStore)
    
    let previousAllocations = self.rawAllocations
    let previousUid = previousAllocations[0]["uid"].rawString()!
    
    mockAllocationStore.put(uid: previousUid, allocations: previousAllocations)
    let cachedAllocations = mockAllocationStore.get(uid: previousUid)
    
    XCTAssertEqual(cachedAllocations, previousAllocations)
    
    let client = EvolvClientFactory(config: mockConfig, participant: participant)
    let verifiedClient = client.client as EvolvClientProtocol
    
    XCTAssertNotNil(verifiedClient)
  }
}
