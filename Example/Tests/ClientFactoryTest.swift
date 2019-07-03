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
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"

  
  private var mockHttpClient : HttpProtocol!
  private var mockAllocationStore : AllocationStoreProtocol!
  private var mockExecutionQueue : ExecutionQueue!
  private var mockConfig : EvolvConfig!
  
    override func setUp() {
      mockHttpClient = HttpClientMock()
      mockAllocationStore = AllocationStoreMock(testCase: self)
      mockExecutionQueue = ExecutionQueueMock()
      mockConfig = ConfigMock("https", "test_domain", "test_v", "test_eid", mockAllocationStore, mockHttpClient)
    }

    override func tearDown() {
      if let _ = mockHttpClient {
        mockHttpClient = nil
      }
      if let _ = mockAllocationStore {
        mockAllocationStore = nil
      }
      if let _ = mockExecutionQueue {
        mockExecutionQueue = nil
      }
      if let _ = mockConfig {
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
    let actualConfig = EvolvConfig.builder(environmentId: environmentId,
                                           httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    var responsePromise = mockHttpClient.get(url: URL(string: anyString(length: 12))!)
    responsePromise = Promise.value(rawAllocation)
    
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    
    let client = EvolvClientFactory(config: mockConfig)
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
  }

  fileprivate func anyString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
  
  func testClientInitSameUser() {
    let participant = EvolvParticipant.builder().setUserId(userId: "test_uid").build()
    var mockClient = HttpClientMock()
    
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockConfig, actualConfig,
                                                                             mockExecutionQueue, mockClient, mockAllocationStore)
    
    let previousAllocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let previousUid = previousAllocations[0]["uid"].rawString()
    // when(mockAllocationStore.get(participant.getUserId())).thenReturn(previousAllocations)
    
    let client = EvolvClientFactory(config: mockConfig, participant: participant)
    // verify(mockAllocationStore, times(2)).get(participant.getUserId())
    // Assert.assertTrue(client instanceof AscendClient)
  }
}
