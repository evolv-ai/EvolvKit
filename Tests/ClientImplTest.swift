//
//  ClientImplTest.swift
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
import PromiseKit
@testable import EvolvKit

class ClientImplTest: XCTestCase {
    
    var mockConfig: EvolvConfig!
    var mockExecutionQueue: EvolvExecutionQueue!
    var mockHttpClient: HttpClientMock!
    var mockAllocationStore: AllocationStoreMock!
    var mockEventEmitter: EvolvEventEmitter!
    var mockAllocator: EvolvAllocator!
    
    private let participant = EvolvParticipant(
        userId: "test_user",
        sessionId: "test_session",
        userAttributes: [
            "userId": "test_user",
            "sessionId": "test_session"
        ])
    private let environmentId = "test_env"
    private var testValue: Double = 0.0
    
    override func setUp() {
        super.setUp()
        
        mockHttpClient = HttpClientMock()
        mockAllocationStore = AllocationStoreMock(testCase: self)
        mockConfig = EvolvConfig(httpScheme: "https",
                                      domain: "test.evolv.ai",
                                      version: "v1",
                                      environmentId: environmentId,
                                      evolvAllocationStore: mockAllocationStore,
                                      httpClient: mockHttpClient)
        mockExecutionQueue = ExecutionQueueMock()
        mockEventEmitter = EventEmitterMock(config: mockConfig, participant: participant)
        mockAllocator = AllocatorMock(config: mockConfig, participant: participant)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockHttpClient = nil
        mockConfig = nil
        mockAllocationStore = nil
        mockExecutionQueue = nil
        mockEventEmitter = nil
        mockAllocator = nil
    }
    
    func testSubscribeStoreNotEmptySubscriptionKey_Valid() {
        let mockStoreWithAllocations = AllocationStoreMockWithAllocations(size: 10)
        let cachedAllocations = mockStoreWithAllocations.get("test_user")
        let config = EvolvConfig(httpScheme: "https",
                                 domain: "test.evolv.ai",
                                 version: "v1",
                                 environmentId: "test_env",
                                 evolvAllocationStore: mockStoreWithAllocations,
                                 httpClient: self.mockHttpClient)
        let emitter = EvolvEventEmitter(config: config, participant: participant)
        
        let subscriptionKey = "search.weighting.distance"
        let defaultValue: Double = 0.001
        
        let promise = Promise { resolver in
            resolver.fulfill(cachedAllocations)
        }
        
        let expect = expectation(description: "key valid")
        let applyFunction: (EvolvRawAllocationNode) -> Void = { value in
            XCTAssertNotEqual(defaultValue, value.doubleValue)
            XCTAssertEqual(value, 2.5)
            expect.fulfill()
        }
        
        let client = DefaultEvolvClient(config: config,
                                        eventEmitter: emitter,
                                        futureAllocations: promise,
                                        allocator: mockAllocator,
                                        previousAllocations: true,
                                        participant: participant)
        client.subscribe(forKey: subscriptionKey, defaultValue: __N(defaultValue), closure: applyFunction)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testSubscribeStoreNotEmptySubscriptionKey_Invalid() {
        let mockStoreWithAllocations = AllocationStoreMockWithAllocations(size: 10)
        let cachedAllocations = mockStoreWithAllocations.get("test_user")
        let config = EvolvConfig(httpScheme: "https",
                                 domain: "test.evolv.ai",
                                 version: "v1",
                                 environmentId: "test_env",
                                 evolvAllocationStore: mockStoreWithAllocations,
                                 httpClient: mockHttpClient)
        let emitter = EvolvEventEmitter(config: config, participant: participant)
        
        let subscriptionKey = "search.weighting.distance.bubbles"
        let defaultValue: Double = 0.001
        
        let promise = Promise { resolver in
            resolver.fulfill(cachedAllocations)
        }
        
        let expect = expectation(description: "call back method key invalid")
        let applyFunction: (EvolvRawAllocationNode) -> Void = { node in
            XCTAssertEqual(defaultValue, node.doubleValue)
            XCTAssertNotEqual(node, 2.5)
            expect.fulfill()
        }
        
        let client = DefaultEvolvClient(config: config,
                                        eventEmitter: emitter,
                                        futureAllocations: promise,
                                        allocator: mockAllocator,
                                        previousAllocations: true,
                                        participant: participant)
        client.subscribe(forKey: subscriptionKey, defaultValue: __N(defaultValue), closure: applyFunction)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testEmitEventWithScore() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: mockAllocator,
                                    previousAllocations: false,
                                    participant: self.participant)
        let key = "testKey"
        let score = 1.3
        client.emitEvent(forKey: key, score: score)
        
        XCTAssertTrue(client.emitEventWithScoreWasCalled)
    }
    
    func testEmitEvent() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: mockAllocator,
                                    previousAllocations: false,
                                    participant: self.participant)
        let key = "testKey"
        client.emitEvent(forKey: key)
        
        XCTAssertTrue(client.emitEventWasCalled)
    }
    
    func testConfirmEventSandBagged() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        
        XCTAssertEqual(mockAllocator.getAllocationStatus(), .fetching)
        
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: participant)
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: mockAllocator,
                                    previousAllocations: false,
                                    participant: participant)
        client.confirm(allocator)
        
        XCTAssertTrue(allocator.sandbagConfirmationWasCalled)
    }
    
    func testConfirmEvent() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: mockAllocator,
                                    previousAllocations: false,
                                    participant: participant)
        let emitter = EventEmitterMock(config: mockConfig, participant: participant)
        client.confirm(emitter, allocations)
        allocator.allocationStatus = .retrieved
        
        XCTAssertEqual(allocator.allocationStatus, .retrieved)
        XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
    }
    
    func testContaminateEventSandBagged() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
        allocator.allocationStatus = .fetching
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: mockAllocator,
                                    previousAllocations: false,
                                    participant: participant)
        client.contaminate(allocator)
        
        XCTAssertEqual(allocator.allocationStatus, .fetching)
        XCTAssertTrue(allocator.sandbagContamationWasCalled)
    }
    
    func testContaminateEvent() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: participant)
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: mockAllocator,
                                    previousAllocations: false,
                                    participant: participant)
        let emitter = EventEmitterMock(config: mockConfig, participant: participant)
        client.contaminate(emitter, allocations)
        allocator.allocationStatus = .retrieved
        
        XCTAssertEqual(allocator.allocationStatus, .retrieved)
        XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
    }
    
    func testSubscribeNoPreviousAllocationsWithFetchingState() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: participant)
        allocator.allocationStatus = .fetching
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: allocator,
                                    previousAllocations: false,
                                    participant: participant)
        
        let expectedTestValue: Double = 2.5
        let defaultValue: Double = 10.01
        
        func updateValue(node: EvolvRawAllocationNode) {
            self.testValue = node.doubleValue
        }
        
        client.subscribe(forKey: "search.weighting.distance", defaultValue: __N(defaultValue), closure: updateValue)
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        self.testValue = 0.0
    }
    
    func testSubscribeNoPreviousAllocationsWithRetrievedState() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
        allocator.allocationStatus = .retrieved
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: allocator,
                                    previousAllocations: false,
                                    participant: participant)
        
        let expectedTestValue: Double = 0.0
        let defaultValue: Double = 10.01
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        
        let expected: Double = 2.5
        func updateValue(node: EvolvRawAllocationNode) {
            self.testValue = node.doubleValue
        }
        
        client.subscribe(forKey: "search.weighting.distance", defaultValue: __N(defaultValue), closure: updateValue)
        XCTAssertEqual(expected, self.testValue)
        self.testValue = 0.0
    }

    func testSubscribeNoPreviousAllocationsWithFailedState() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
        allocator.allocationStatus = .failed
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: allocator,
                                    previousAllocations: false,
                                    participant: participant)
        
        let expectedTestValue: Double = 0.0
        let defaultValue: Double = 10.01
        
        XCTAssertEqual(expectedTestValue, testValue)
        
        let expected: Double = 2.5
        func updateValue(node: EvolvRawAllocationNode) {
            self.testValue = node.doubleValue
        }
        
        client.subscribe(forKey: "search.weighting.distance", defaultValue: __N(defaultValue), closure: updateValue)
        XCTAssertEqual(expected, self.testValue)
        self.testValue = 0.0
    }
    
    func testSubscribeNoPreviousAllocationsWithRetrievedStateThrowsError() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
        allocator.allocationStatus = .failed
        
        let client = ClientMock(config: mockConfig,
                                    eventEmitter: mockEventEmitter,
                                    futureAllocations: promise,
                                    allocator: allocator,
                                    previousAllocations: false,
                                    participant: participant)
        
        let expectedTestValue: Double = 0.0
        let defaultValue: Double = 10.01
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        
        let expected: Double = 2.5
        func updateValue(node: EvolvRawAllocationNode) {
            self.testValue = node.doubleValue
        }
        
        client.subscribe(forKey: "not.a.valid.key", defaultValue: __N(defaultValue), closure: updateValue)
        XCTAssertNotEqual(expected, self.testValue)
        self.testValue = 0.0
    }
    
}
