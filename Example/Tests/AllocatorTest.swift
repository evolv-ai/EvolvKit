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
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  
  private var mockConfig: EvolvConfig!
  private var mockExecutionQueue: ExecutionQueue!
  private var mockHttpClient : HttpClientMock!
  private var mockAllocationStore : AllocationStoreProtocol!
  
  override func setUp() {
    mockExecutionQueue = ExecutionQueue()
    mockHttpClient = HttpClientMock()
    mockAllocationStore = DefaultAllocationStore(size: 1)
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
  
  func setUpMockedEvolvConfigWithMockedClient(_ mockedConfig: EvolvConfig, _ actualConfig: EvolvConfig,
                                              _ mockExecutionQueue: ExecutionQueue, _ mockHttpClient: HttpProtocol,
                                              _ mockAllocationStore: AllocationStoreProtocol) -> EvolvConfig {
    
    return EvolvConfig(actualConfig.getHttpScheme(), actualConfig.getDomain(),
                       actualConfig.getVersion(), actualConfig.getEnvironmentId(),
                       mockAllocationStore, mockHttpClient)
  }
  
  func createAllocationsUrl(config: EvolvConfig, participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    return url
  }
  
  func createConfirmationUrl(_ config: EvolvConfig, _ allocation: JSON, _ participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(allocation[0]["eid"].stringValue)"),
      URLQueryItem(name: "cid", value: "\(allocation[0]["cid"].stringValue)"),
      URLQueryItem(name: "type", value: "confirmation")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    print("URL: \(url)")
    return url
  }
  
  func createContaminationUrl(config: EvolvConfig, allocation: [JSON], participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(allocation[0]["eid"].stringValue)"),
      URLQueryItem(name: "cid", value: "\(allocation[0]["cid"].stringValue)"),
      URLQueryItem(name: "type", value: "contamination")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    print("URL: \(url)")
    return url
  }
  
  func testCreateAllocationsUrl() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
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
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    
    XCTAssertFalse(Allocator.allocationsNotEmpty(allocations: nilAllocations))
    XCTAssertFalse(Allocator.allocationsNotEmpty(allocations: emptyAllocations))
    XCTAssertTrue(Allocator.allocationsNotEmpty(allocations: allocations))
  }
  
  func testResolveAllocationFailureWithAllocationsInStore() -> Void {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocations)
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    
    let allocator = Allocator(config: mockConfig, participant: participant)
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Execute All With Values From Allocations")
    try! mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.RETRIEVED, allocator.getAllocationStatus())
    XCTAssertEqual(allocations, actualAllocations)
  }
  
  func testResolveAllocationFailureWithAllocationsInStoreWithSandbaggedConfirmation() -> Void {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocations)
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    
    let allocator = Allocator(config: mockConfig, participant: participant)
    
    allocator.sandbagConfirmation()
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Create Confirmation Url, Get Allocations From Store")
    mockHttpClient.get(url: createConfirmationUrl(actualConfig, allocations[0], participant))
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    let exp2 = expectation(description: "Execute All With Values From Allocations")
    try! mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp2.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(exp2.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.RETRIEVED, allocator.getAllocationStatus())
    XCTAssertEqual(allocations, actualAllocations)
  }
  
  func testResolveAllocationFailureWithAllocationsInStoreWithSandbaggedContamination() -> Void {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocations)
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    
    let allocator = Allocator(config: mockConfig, participant: participant)
    allocator.sandbagContamination()
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Create Contaminatin Url, Get Allocations From Store")
    mockHttpClient.get(url: createConfirmationUrl(actualConfig, allocations[0], participant))
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    let exp2 = expectation(description: "Execute All With Values From Allocations")
    try! mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp2.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(exp2.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.RETRIEVED, allocator.getAllocationStatus())
    XCTAssertEqual(allocations, actualAllocations)
  }
  
  func testResolveAllocationFailureWithNoAllocationsInStore() -> Void {
    let participant = EvolvParticipant.builder().build()
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let allocations = mockAllocationStore.get(uid: participant.getUserId())
    
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue, mockHttpClient, mockAllocationStore)
    let allocator = Allocator(config: mockConfig, participant: participant)
    allocator.sandbagContamination()
    
    let actualAllocations = allocator.resolveAllocationsFailure()
    
    let exp = expectation(description: "Execute All With Values From Allocations")
    try! mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    exp.fulfill()
    waitForExpectations(timeout: 3)
    
    XCTAssertEqual(exp.expectedFulfillmentCount, 1)
    XCTAssertEqual(Allocator.AllocationStatus.FAILED, allocator.getAllocationStatus())
    XCTAssertEqual([JSON](), actualAllocations)
  }
  
  func testFetchAllocationsWithNoAllocationsInStore() {
    let participant = EvolvParticipant.builder().build()
    let rawAllocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocationsEmpty = mockAllocationStore.get(uid: participant.getUserId())
    var allocationsPromiseResolved = [JSON]()
    let allocator = Allocator(config: mockConfig, participant: participant)
    let allocationsPromise = allocator.fetchAllocations()
    

    XCTAssertNotNil(allocationsPromise)
    XCTAssertNotEqual(rawAllocations, allocationsEmpty)
    XCTAssertEqual(allocationsEmpty, [JSON]())
  }
  
  func testAllocationsReconciliation() -> Void {
    let participant = EvolvParticipant.builder().build()
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocationsJson = AllocationsTest().parseRawAllocations(raw: rawAllocation)

    mockAllocationStore.put(uid: participant.getUserId(), allocations: allocationsJson)
    
    let previous = mockAllocationStore.get(uid: participant.getUserId())
    let reconciled = Allocations.reconcileAllocations(previousAllocations: previous,
                                    currentAllocations: allocations)
    
    XCTAssertEqual(allocations, reconciled)
  }
  
  func testAllocationsNotEmptyFunction() {
    let participant = EvolvParticipant.builder().build()
    let emptyAllocations = mockAllocationStore.get(uid: participant.getUserId())
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    
    XCTAssertNotNil(emptyAllocations)
    XCTAssertTrue(emptyAllocations == [JSON]())
    XCTAssertTrue(allocations != [JSON]())
    XCTAssertFalse(emptyAllocations == allocations)
  }
}
