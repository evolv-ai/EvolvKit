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
  private let testValue: Double = 0.0
  
  override func setUp() {
    self.mockHttpClient = HttpClientMock()
    self.mockAllocationStore = AllocationStoreMock(testCase: self)
    self.mockConfig = EvolvConfig("https", "test.evolv.ai", "v1", self.environmentId, self.mockAllocationStore, self.mockHttpClient)
    self.mockExecutionQueue = ExecutionQueueMock()
    self.mockEventEmitter = EventEmitter(config: self.mockConfig, participant: self.participant)
    self.mockAllocator = Allocator(config: self.mockConfig, participant: self.participant)
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
  
  func testGetReturnsDefaultsUponNullFuture() {
    let subscriptionKey = "foo.bar"
    let defaultValue = "FooBar"
    let applyFunction: (String) -> Void = { value in
      
    }
    
    let participantId = "id"
    
    let participant = EvolvParticipant(userId: participantId, sessionId: "sid", userAttributes: [
      "userId": "id",
      "sessionId": "sid"
      ])
    
    self.mockAllocationStore.expectGet { uid -> [JSON] in
      XCTAssertEqual(uid, participantId)
      
      return [JSON]()
    }
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.mockAllocationStore, self.mockHttpClient)
    let emitter = EventEmitter(config: config, participant: participant)
    let promise = Promise<[JSON]>.pending().promise
    let allocator = Allocator(config: config, participant: participant)
    
    let client = EvolvClientImpl(config, emitter, promise, allocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    self.waitForExpectations(timeout: 5)
  }
  
  func testSubscribe_AllocationStoreIsNotEmpty_SubscriptionKeyIsValid_() {
    let subscriptionKey = "foo.bar"
    let defaultValue = "FooBar"
    let applyFunction: (String) -> Void = { value in
      // XCTAssertEqual(<#T##expression1: Equatable##Equatable#>, <#T##expression2: Equatable##Equatable#>)
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
  
  func testEvolvParticipant() {
    let p = EvolvParticipant.builder().build()
    p.setUserId(userId: "test_user")
    XCTAssertEqual(p.getUserId(), "test_user")
  }
  
}

