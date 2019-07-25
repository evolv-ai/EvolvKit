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
  
  private var mockExecutionQueue: ExecutionQueueMock!
  private var participant: EvolvParticipant!
  
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
  private var mockHttpClient: HttpClientMock!
  private var mockAllocationStore: AllocationStoreProtocol!
  
  override func setUp() {
    super.setUp()
    
    self.mockExecutionQueue = ExecutionQueueMock()
    self.participant = EvolvParticipant.builder().build()
    mockHttpClient = HttpClientMock()
    mockAllocationStore = DefaultAllocationStore(size: 10)
    
    mockConfig = ConfigMock("https", "test_domain", "test_v", "test_eid", mockAllocationStore, mockHttpClient)
  }
  
  override func tearDown() {
    super.tearDown()
    
    if mockExecutionQueue != nil {
      mockExecutionQueue = nil
    }
    if participant != nil {
      participant = nil
    }
  }

  // Mock executions for the execution queue
  func printSomething<T>(value: T) { print("some value: \(value)") }
  func doSomething(key: String) { print("Did something with \(key)!") }
  
  func testEnqueue() {
    let key = "pages.testing_page.header"
    let defaultValue = "red"
    let execution = ExecutionMock(key, defaultValue, participant, printSomething)
    
    mockExecutionQueue.enqueue(execution)
    XCTAssertEqual(mockExecutionQueue.count, 1)
    XCTAssertTrue(mockExecutionQueue != nil)
    
    mockExecutionQueue.enqueue(execution)
    mockExecutionQueue.enqueue(execution)
    mockExecutionQueue.enqueue(execution)
    
    XCTAssertEqual(mockExecutionQueue.count, 4)
  }
  
  func testExecuteAllWithValuesFromAllocations() {
    let key = "pages.testing_page.header"
    let defaultValue = "red"
    let exMock1 = ExecutionMock(key, defaultValue, participant, printSomething)
    let exMock2 = ExecutionMock("pages.testing_page.header", "red", participant, doSomething)
    
    let allocations = self.rawAllocations
    
    mockExecutionQueue.enqueue(exMock1)
    mockExecutionQueue.enqueue(exMock2)
    
    XCTAssertEqual(mockExecutionQueue.count, 2)
    
    // Should pop an execution from the queue
    mockExecutionQueue.executeAllWithValuesFromAllocations(allocations)
    
    XCTAssertEqual(mockExecutionQueue.count, 1)
    XCTAssertTrue(mockExecutionQueue.executeValuesFromAllocationsWasCalled)
  }
  
  func testExecuteAllWithValuesFromDefaults() {
    let key = "pages.testing_page_typo.header_typo"
    let defaultValue = "red"
    let exMock1 = ExecutionMock(key, defaultValue, participant, printSomething)
    let exMock2 = ExecutionMock(key, defaultValue, participant, doSomething)
    
    mockExecutionQueue.enqueue(exMock1)
    mockExecutionQueue.enqueue(exMock2)
    
    XCTAssertEqual(mockExecutionQueue.count, 2)
    
    // Should pop an execution from the queue
    mockExecutionQueue.executeAllWithValuesFromDefaults()

    XCTAssertEqual(mockExecutionQueue.count, 1)
    XCTAssertTrue(mockExecutionQueue.executeWithDefaultsWasCalled)
  }
  
}
