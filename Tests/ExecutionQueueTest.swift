//
//  ExecutionQueueTest.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
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
    func printSomething(node: EvolvRawAllocationNode) {
        print("some value: \(node.value)")
    }
    
    func doSomething(node: EvolvRawAllocationNode) {
        print("Did something with \(node.stringValue)!")
    }
    
    func testEnqueue() {
        let key = "pages.testing_page.header"
        let defaultValue = "red"
        let execution = ExecutionMock(key: key,
                                      defaultValue: __N(defaultValue),
                                      participant: participant, store: mockAllocationStore,
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
        let exMock1 = ExecutionMock(key: key,
                                    defaultValue: __N(defaultValue),
                                    participant: participant,
                                    store: mockAllocationStore,
                                    closure: printSomething)
        let exMock2 = ExecutionMock(key: "pages.testing_page.header",
                                    defaultValue: __N("red"),
                                    participant: participant,
                                    store: mockAllocationStore,
                                    closure: doSomething)
        
        let allocations = TestData.rawAllocations
        
        mockExecutionQueue.enqueue(exMock1)
        mockExecutionQueue.enqueue(exMock2)
        
        XCTAssertEqual(mockExecutionQueue.count, 2)
        
        // Should pop an execution from the queue
        mockExecutionQueue.executeAllWithValues(from: allocations)
        
        XCTAssertEqual(mockExecutionQueue.count, 0)
        XCTAssertTrue(mockExecutionQueue.executeValuesFromAllocationsWasCalled)
    }
    
    func testExecuteAllWithValuesFromDefaults() {
        let key = "pages.testing_page_typo.header_typo"
        let defaultValue = "red"
        let exMock1 = ExecutionMock(key: key,
                                    defaultValue: __N(defaultValue),
                                    participant: participant,
                                    store: mockAllocationStore,
                                    closure: printSomething)
        let exMock2 = ExecutionMock(key: key,
                                    defaultValue: __N(defaultValue),
                                    participant: participant,
                                    store: mockAllocationStore,
                                    closure: doSomething)
        
        mockExecutionQueue.enqueue(exMock1)
        mockExecutionQueue.enqueue(exMock2)
        
        XCTAssertEqual(mockExecutionQueue.count, 2)
        
        // Should pop an execution from the queue
        mockExecutionQueue.executeAllWithValuesFromDefaults()
        
        XCTAssertEqual(mockExecutionQueue.count, 0)
        XCTAssertTrue(mockExecutionQueue.executeWithDefaultsWasCalled)
    }
    
}
