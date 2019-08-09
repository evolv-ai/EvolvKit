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
    private var mockConfig: EvolvConfig!
    private var mockHttpClient: HttpClientMock!
    private var mockAllocationStore: EvolvAllocationStore!
    
    override func setUp() {
        super.setUp()
        
        self.mockExecutionQueue = ExecutionQueueMock()
        self.participant = EvolvParticipant.builder().build()
        mockHttpClient = HttpClientMock()
        mockAllocationStore = DefaultEvolvAllocationStore(size: 10)
        
        mockConfig = ConfigMock(httpScheme: "https",
                                domain: "test_domain",
                                version: "test_v",
                                environmentId: "test_eid",
                                evolvAllocationStore: mockAllocationStore,
                                httpClient: mockHttpClient)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockExecutionQueue = nil
        participant = nil
    }
    
    // Mock executions for the execution queue
    func printSomething<T>(value: T) {
        print("some value: \(value)")
    }
    
    func doSomething(key: String) {
        print("Did something with \(key)!")
    }
    
    func testEnqueue() {
        let key = "pages.testing_page.header"
        let defaultValue = "red"
        let execution = ExecutionMock(key: key,
                                      defaultValue: defaultValue,
                                      participant: participant,
                                      closure: printSomething)
        
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
        let exMock1 = ExecutionMock(key: key, defaultValue: defaultValue, participant: participant, closure: printSomething)
        let exMock2 = ExecutionMock(key: "pages.testing_page.header", defaultValue: "red", participant: participant, closure: doSomething)
        
        let allocations = TestData.rawAllocations
        
        mockExecutionQueue.enqueue(exMock1)
        mockExecutionQueue.enqueue(exMock2)
        
        XCTAssertEqual(mockExecutionQueue.count, 2)
        
        // Should pop an execution from the queue
        mockExecutionQueue.executeAllWithValues(from: allocations)
        
        XCTAssertEqual(mockExecutionQueue.count, 1)
        XCTAssertTrue(mockExecutionQueue.executeValuesFromAllocationsWasCalled)
    }
    
    func testExecuteAllWithValuesFromDefaults() {
        let key = "pages.testing_page_typo.header_typo"
        let defaultValue = "red"
        let exMock1 = ExecutionMock(key: key, defaultValue: defaultValue, participant: participant, closure: printSomething)
        let exMock2 = ExecutionMock(key: key, defaultValue: defaultValue, participant: participant, closure: doSomething)
        
        mockExecutionQueue.enqueue(exMock1)
        mockExecutionQueue.enqueue(exMock2)
        
        XCTAssertEqual(mockExecutionQueue.count, 2)
        
        // Should pop an execution from the queue
        mockExecutionQueue.executeAllWithValuesFromDefaults()
        
        XCTAssertEqual(mockExecutionQueue.count, 1)
        XCTAssertTrue(mockExecutionQueue.executeWithDefaultsWasCalled)
    }
    
}
