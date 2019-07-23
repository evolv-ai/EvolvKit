import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class ClientImplTest: XCTestCase {
  
  var mockConfig : EvolvConfig!
  var mockExecutionQueue : ExecutionQueue!
  var mockHttpClient : HttpClientMock!
  var mockAllocationStore: AllocationStoreMock!
  var mockEventEmitter : EventEmitter!
  var mockAllocator : Allocator!
  
  private let participant = EvolvParticipant(userId: "test_user", sessionId: "test_session", userAttributes: [
      "userId": "test_user",
      "sessionId": "test_session"
    ])
  
  private let environmentId = "test_env"
  private let rawAllocation = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  private var testValue: Double = 0.0
  
  override func setUp() {
    self.mockHttpClient = HttpClientMock()
    self.mockAllocationStore = AllocationStoreMock(testCase: self)
    self.mockConfig = EvolvConfig("https", "test.evolv.ai", "v1", self.environmentId, self.mockAllocationStore, self.mockHttpClient)
    self.mockExecutionQueue = ExecutionQueueMock()
    self.mockEventEmitter = EmitterMock(config: self.mockConfig, participant: self.participant)
    self.mockAllocator = AllocatorMock(config: self.mockConfig, participant: self.participant)
  }
  
  override func tearDown() {
    if let _ = mockHttpClient {
      mockHttpClient = nil
    }
    if let _ = mockConfig {
      mockConfig = nil
    }
    if let _ = mockAllocationStore {
      mockAllocationStore = nil
    }
    if let _ = mockExecutionQueue {
      mockExecutionQueue = nil
    }
    if let _ = mockEventEmitter {
      mockEventEmitter = nil
    }
    if let _ = mockAllocator {
      mockAllocator = nil
    }
  }
  
  func testSubscribe_AllocationStoreNotEmpty_SubscriptionKeyIsValid() {
    let subscriptionKey = "search.weighting"
    let defaultValue: Double = 0.001
    let applyFunction: (Double) -> Void = { value in
      XCTAssertNotEqual(defaultValue, value)
    }
    
    let participantId = "id"
    
    let participant = EvolvParticipant(userId: participantId, sessionId: "sid", userAttributes: [
      "userId": "id",
      "sessionId": "sid"
      ])
    
    self.mockAllocationStore.expectGet { uid -> [JSON] in
      XCTAssertEqual(uid, participantId)
      
      let myStoredAllocation = "[{\"uid\":\"\(participantId)\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_1\",\"buttons\":{\"checkout\":{\"text\":\"Begin Secure Checkout\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"Product Specifications\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
      let dataFromString = myStoredAllocation.data(using: String.Encoding.utf8, allowLossyConversion: false)!
      let allocations = try! JSON(data: dataFromString).arrayValue
      
      return allocations
    }
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.mockAllocationStore, self.mockHttpClient)
    let emitter = EventEmitter(config: config, participant: participant)
    let promise = Promise<[JSON]>.pending().promise
    let allocator = Allocator(config: config, participant: participant)
    
    let client = EvolvClientImpl(config, emitter, promise, allocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    self.waitForExpectations(timeout: 5)
  }
  
  func testSubscribe_AllocationStoreNotEmpty_SubscriptionKeyInvalid() {
    let subscriptionKey = "search.weighting.distance.bubbles"
    let defaultValue: Double = 0.001
    
    let applyFunction: (Double) -> Void = { value in
      XCTAssertEqual(defaultValue, value)
    }
    
    let participantId = "id"
    
    let participant = EvolvParticipant(userId: participantId, sessionId: "sid", userAttributes: [
      "userId": "id",
      "sessionId": "sid"
      ])
    
    self.mockAllocationStore.expectGet { uid -> [JSON] in
      XCTAssertEqual(uid, participantId)
      
      let myStoredAllocation = "[{\"uid\":\"\(participantId)\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_1\",\"buttons\":{\"checkout\":{\"text\":\"Begin Secure Checkout\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"Product Specifications\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
      let dataFromString = myStoredAllocation.data(using: String.Encoding.utf8, allowLossyConversion: false)!
      let allocations = try! JSON(data: dataFromString).arrayValue
      
      return allocations
    }
    
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.mockAllocationStore, self.mockHttpClient)
    let emitter = EventEmitter(config: config, participant: participant)
    let promise = Promise<[JSON]>.pending().promise
    let allocator = Allocator(config: config, participant: participant)
    
    let client = EvolvClientImpl(config, emitter, promise, allocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    self.waitForExpectations(timeout: 5)
  }
  
  func testEmitEventWithScore() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let key = "testKey"
    let score = 1.3
    client.emitEvent(key: key, score: score)
    
    XCTAssertTrue(client.emitEventWithScoreWasCalled)
  }
  
  func testEmitEvent() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let key = "testKey"
    client.emitEvent(key: key)
    
    XCTAssertTrue(client.emitEventWasCalled)
  }
  
  func testConfirmEventSandBagged() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    
    XCTAssertEqual(mockAllocator.getAllocationStatus(), Allocator.AllocationStatus.FETCHING)
    
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    client.confirm(allocator: allocator)
    
    XCTAssertTrue(allocator.sandbagConfirmationWasCalled)
  }
  
  func testConfirmEvent() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let emitter = EmitterMock(config: self.mockConfig, participant: self.participant)
    client.confirm(eventEmitter: emitter, allocations: allocations)
    allocator.allocationStatus = Allocator.AllocationStatus.RETRIEVED
    
    XCTAssertEqual(allocator.getAllocationStatus(), Allocator.AllocationStatus.RETRIEVED)
    XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
  }
  
  func testContaminateEventSandBagged() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.FETCHING
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    client.contaminate(allocator: allocator)
    
    XCTAssertEqual(allocator.getAllocationStatus(), Allocator.AllocationStatus.FETCHING)
    XCTAssertTrue(allocator.sandbagContamationWasCalled)
  }
  
  func testContaminateEvent() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let emitter = EmitterMock(config: self.mockConfig, participant: self.participant)
    client.contaminate(eventEmitter: emitter, allocations: allocations)
    allocator.allocationStatus = Allocator.AllocationStatus.RETRIEVED
    
    XCTAssertEqual(allocator.getAllocationStatus(), Allocator.AllocationStatus.RETRIEVED)
    XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
  }
  
  func testSubscribeNoPreviousAllocationsWithFetchingState() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    var promise = Promise<[JSON]>.pending().promise
    let responsePromise = Promise.value(rawAllocation)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.FETCHING
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
    
    let expectedTestValue: Double = 10.01
    let defaultValue: Double = 10.01
    
    func updateValue(value: Double) {
      self.testValue = value
    }
    
    client.subscribe(key: "search.weighting.distance", defaultValue: defaultValue, function: updateValue)
    
    XCTAssertEqual(expectedTestValue, self.testValue)
    self.testValue = 0.0
  }
  
  func testSubscribeNoPreviousAllocationsWithRetrievedState() {}
  
  func testSubscribeNoPreviousAllocationsWithFailedState() {}
  
  func testSubscribeNoPreviousAllocationsWithRetrievedStateThrowsError() {}
  
}

