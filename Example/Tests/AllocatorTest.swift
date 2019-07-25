//
//  AllocatorTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class AllocatorTest: XCTestCase {
  
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
  
  private var mockConfig: EvolvConfig!
  private var mockExecutionQueue: ExecutionQueue!
  private var mockHttpClient: HttpClientMock!
  private var mockAllocationStore: AllocationStoreProtocol!
  
  override func setUp() {
    super.setUp()
    
    mockExecutionQueue = ExecutionQueue()
    mockHttpClient = HttpClientMock()
    mockAllocationStore = DefaultAllocationStore(size: 1)
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
  
  func setUpMockedEvolvConfigWithMockedClient(_ mockedConfig: EvolvConfig, _ actualConfig: EvolvConfig,
                                              _ mockExecutionQueue: ExecutionQueue, _ mockHttpClient: HttpProtocol,
                                              _ mockAllocationStore: AllocationStoreProtocol) -> EvolvConfig {
    
    return EvolvConfig(actualConfig.getHttpScheme(), actualConfig.getDomain(),
                       actualConfig.getVersion(), actualConfig.getEnvironmentId(),
                       mockAllocationStore, mockHttpClient)
  }
  
  func createUrlComponents(_ config: EvolvConfig) -> URLComponents {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    return components
  }
  
  func createAllocationsUrl(config: EvolvConfig, participant: EvolvParticipant) -> URL {
    var components = createUrlComponents(config)
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())")
    ]
    
    return components.url!
  }
  
  func createConfirmationUrl(_ config: EvolvConfig, _ allocation: [JSON], _ participant: EvolvParticipant) -> URL {
    var components = createUrlComponents(config)
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(allocation[0]["eid"].stringValue)"),
      URLQueryItem(name: "cid", value: "\(allocation[0]["cid"].stringValue)"),
      URLQueryItem(name: "type", value: "confirmation")
    ]
    
    return components.url!
  }
  
  func createContaminationUrl(_ config: EvolvConfig, _ allocation: [JSON], _ participant: EvolvParticipant) -> URL {
    var components = createUrlComponents(config)
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(allocation[0]["eid"].stringValue)"),
      URLQueryItem(name: "cid", value: "\(allocation[0]["cid"].stringValue)"),
      URLQueryItem(name: "type", value: "contamination")
    ]
    
    return components.url!
  }
  
  func testCreateAllocationsUrl() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                            mockExecutionQueue, mockHttpClient,
                                                            mockAllocationStore)
    let participant = EvolvParticipant.builder().build()
    let allocator = Allocator(config: mockConfig, participant: participant)
    let actualUrl = allocator.createAllocationsUrl()
    let expectedUrl = createAllocationsUrl(config: actualConfig, participant: participant)
    
    XCTAssertEqual(expectedUrl, actualUrl)
  }
  
  func testAllocationsNotEmpty() {
    let nilAllocations: [JSON]? = nil
    let emptyAllocations = [JSON]()
    let allocations = self.rawAllocations
    
    XCTAssertFalse(Allocator.allocationsNotEmpty(allocations: nilAllocations))
    XCTAssertFalse(Allocator.allocationsNotEmpty(allocations: emptyAllocations))
    XCTAssertTrue(Allocator.allocationsNotEmpty(allocations: allocations))
  }
  
  func testResolveAllocationFailureWithAllocationsInStore() {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let allocations = self.rawAllocations

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocations)
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    
    let allocator = Allocator(config: mockConfig, participant: participant)
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Execute All With Values From Allocations")
    try? mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.RETRIEVED, allocator.getAllocationStatus())
    XCTAssertEqual(allocations, actualAllocations)
  }
  
  func testResolveAllocationFailureWithAllocationsInStoreWithSandbaggedConfirmation() {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let allocations = self.rawAllocations

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocations)
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    
    let allocator = Allocator(config: mockConfig, participant: participant)
    
    allocator.sandbagConfirmation()
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Create Confirmation Url, Get Allocations From Store")
    mockHttpClient.get(url: createConfirmationUrl(actualConfig, allocations, participant))
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    let exp2 = expectation(description: "Execute All With Values From Allocations")
    try? mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp2.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(exp2.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.RETRIEVED, allocator.getAllocationStatus())
    XCTAssertEqual(allocations, actualAllocations)
  }
  
  func testResolveAllocationFailureWithAllocationsInStoreWithSandbaggedContamination() {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let allocations = self.rawAllocations

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocations)
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    
    let allocator = Allocator(config: mockConfig, participant: participant)
    allocator.sandbagContamination()
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Create Contaminatin Url, Get Allocations From Store")
    mockHttpClient.get(url: createConfirmationUrl(actualConfig, allocations, participant))
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    let exp2 = expectation(description: "Execute All With Values From Allocations")
    try? mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp2.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(exp2.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.RETRIEVED, allocator.getAllocationStatus())
    XCTAssertEqual(allocations, actualAllocations)
  }
  
  func testResolveAllocationFailureWithNoAllocationsInStore() {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let allocations = mockAllocationStore.get(uid: participant.getUserId())
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    let allocator = Allocator(config: mockConfig, participant: participant)
    allocator.sandbagContamination()
    
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Execute All With Values From Allocations")
    try? mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.FAILED, allocator.getAllocationStatus())
    XCTAssertEqual([JSON](), actualAllocations)
  }
  
  func testFetchAllocationsWithNoAllocationsInStore() {
    let participant = EvolvParticipant.builder().build()
    let rawAllocations = self.rawAllocations
    let allocationsEmpty = mockAllocationStore.get(uid: participant.getUserId())
    let allocator = Allocator(config: mockConfig, participant: participant)
    let allocationsPromise = allocator.fetchAllocations()

    XCTAssertNotNil(allocationsPromise)
    XCTAssertNotEqual(rawAllocations, allocationsEmpty)
    XCTAssertEqual(allocationsEmpty, [JSON]())
  }
  
  func testAllocationsReconciliation() {
    let participant = EvolvParticipant.builder().build()
    let allocations = self.rawAllocations
    let allocationsJson = self.rawAllocations

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocationsJson)
    
    let previous = mockAllocationStore.get(uid: participant.getUserId())
    let reconciled = Allocations.reconcileAllocations(previousAllocations: previous,
                                    currentAllocations: allocations)
    
    XCTAssertEqual(allocations, reconciled)
  }
  
  func testAllocationsNotEmptyFunction() {
    let participant = EvolvParticipant.builder().build()
    let emptyAllocations = mockAllocationStore.get(uid: participant.getUserId())
    let allocations = self.rawAllocations
    
    XCTAssertNotNil(emptyAllocations)
    XCTAssertTrue(emptyAllocations == [JSON]())
    XCTAssertTrue(allocations != [JSON]())
    XCTAssertFalse(emptyAllocations == allocations)
  }
}
