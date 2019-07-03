//
//  ExecutionQueueTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import EvolvKit

class ExecutionQueueTest: XCTestCase {
  
  private var mockExecutionQueue : ExecutionQueueMock!
  private var participant : EvolvParticipant!
  
  private let environmentId: String = "test_12345"
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  
  private var mockConfig: EvolvConfig!
  private var mockHttpClient : HttpClientMock!
  private var mockAllocationStore : AllocationStoreProtocol!
  
  override func setUp() {
    self.mockExecutionQueue = ExecutionQueueMock()
    self.participant = EvolvParticipant.builder().build()
    mockHttpClient = HttpClientMock()
    mockAllocationStore = DefaultAllocationStore(size: 10)
    
    mockConfig = ConfigMock("https", "test_domain", "test_v", "test_eid", mockAllocationStore, mockHttpClient)
  }
  
  override func tearDown() {
    if let _ = mockExecutionQueue {
      self.mockExecutionQueue = nil
    }
    if let _ = participant {
      self.participant = nil
    }
  }
  
  func parseRawAllocations(raw: String) -> [JSON] {
    var allocations = [JSON]()
    if let dataFromString = raw.data(using: String.Encoding.utf8, allowLossyConversion: false) {
      allocations = try! JSON(data: dataFromString).arrayValue
    }
    return allocations
  }

  // Mock executions for the execution queue
  func printSomething<T>(value: T) { print("some value: \(value)") }
  func doSomething(key: String) -> () { print("Did something with \(key)!") }
  
  
  func testEnqueue() {
    let key = "pages.testing_page.header"
    let defaultValue = "red"
    let ex = ExecutionMock(key, defaultValue, participant, printSomething)
    
    mockExecutionQueue.enqueue(execution: ex)
    XCTAssertEqual(mockExecutionQueue.count, 1)
    XCTAssertTrue(mockExecutionQueue != nil)
    
    mockExecutionQueue.enqueue(execution: ex)
    mockExecutionQueue.enqueue(execution: ex)
    mockExecutionQueue.enqueue(execution: ex)
    
    XCTAssertEqual(mockExecutionQueue.count, 4)
  }
  
  func testExecuteAllWithValuesFromAllocations() {
    let key = "pages.testing_page.header"
    let defaultValue = "red"
    let exMock1 = ExecutionMock(key, defaultValue, participant, printSomething)
    let exMock2 = ExecutionMock("pages.testing_page.header", "red", participant, doSomething)
    
    let allocations = parseRawAllocations(raw: rawAllocation)
    
    mockExecutionQueue.enqueue(execution: exMock1)
    mockExecutionQueue.enqueue(execution: exMock2)
    
    XCTAssertEqual(mockExecutionQueue.count, 2)
    
    // Should pop an execution from the queue
    mockExecutionQueue.executeAllWithValuesFromAllocations(allocations: allocations)
    
    XCTAssertEqual(mockExecutionQueue.count, 1)
    XCTAssertTrue(mockExecutionQueue.executeAllWithValuesFromAllocationsWasCalled)
  }

  func testExecuteAllWithValuesFromDefaults() {
    let key = "pages.testing_page_typo.header_typo"
    let defaultValue = "red"
    let exMock1 = ExecutionMock(key, defaultValue, participant, printSomething)
    let exMock2 = ExecutionMock(key, defaultValue, participant, doSomething)
    
    mockExecutionQueue.enqueue(execution: exMock1)
    mockExecutionQueue.enqueue(execution: exMock2)
    
    XCTAssertEqual(mockExecutionQueue.count, 2)
    
    // Should pop an execution from the queue
    mockExecutionQueue.executeAllWithValuesFromDefaults()

    XCTAssertEqual(mockExecutionQueue.count, 1)
    XCTAssertTrue(mockExecutionQueue.executeAllWithValuesFromDefaultsWasCalled)
  }
  
}
