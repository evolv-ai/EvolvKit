import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class ClientImplTest: XCTestCase {
    
    var mockConfig: EvolvConfig!
    var mockExecutionQueue: ExecutionQueue!
    var mockHttpClient: HttpClientMock!
    var mockAllocationStore: AllocationStoreMock!
    var mockEventEmitter: EventEmitter!
    var mockAllocator: Allocator!
    
    private let participant = EvolvParticipant("test_user", "test_session", [
        "userId": "test_user",
        "sessionId": "test_session"
        ])
    private let environmentId = "test_env"
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
    private var testValue: Double = 0.0
    
    override func setUp() {
        super.setUp()
        
        self.mockHttpClient = HttpClientMock()
        self.mockAllocationStore = AllocationStoreMock(testCase: self)
        self.mockConfig = EvolvConfig("https",
                                      "test.evolv.ai",
                                      "v1",
                                      self.environmentId,
                                      self.mockAllocationStore,
                                      self.mockHttpClient)
        self.mockExecutionQueue = ExecutionQueueMock()
        self.mockEventEmitter = EmitterMock(self.mockConfig, self.participant)
        self.mockAllocator = AllocatorMock(self.mockConfig, self.participant)
    }
    
    override func tearDown() {
        super.tearDown()
        
        if mockHttpClient != nil {
            mockHttpClient = nil
        }
        
        if mockConfig != nil {
            mockConfig = nil
        }
        
        if mockAllocationStore != nil {
            mockAllocationStore = nil
        }
        
        if mockExecutionQueue != nil {
            mockExecutionQueue = nil
        }
        
        if mockEventEmitter != nil {
            mockEventEmitter = nil
        }
        
        if mockAllocator != nil {
            mockAllocator = nil
        }
    }
    
    func testSubscribeStoreNotEmptySubscriptionKey_Valid() {
        let mockStoreWithAllocations = AllocationStoreMockWithAllocations(size: 10)
        let cachedAllocations = mockStoreWithAllocations.get("test_user")
        let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env",
                                 mockStoreWithAllocations, self.mockHttpClient)
        let emitter = EventEmitter(config, participant)
        
        let subscriptionKey = "search.weighting.distance"
        let defaultValue: Double = 0.001
        
        let promise = Promise { resolver in
            resolver.fulfill(cachedAllocations)
        }
        
        let expect = expectation(description: "key valid")
        let applyFunction: (Double) -> Void = { value in
            XCTAssertNotEqual(defaultValue, value)
            XCTAssertEqual(value, 2.5)
            expect.fulfill()
        }
        
        let client = EvolvClientImpl(config, emitter, promise, mockAllocator, true, participant)
        client.subscribe(subscriptionKey, defaultValue, applyFunction)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testSubscribeStoreNotEmptySubscriptionKey_Invalid() {
        let mockStoreWithAllocations = AllocationStoreMockWithAllocations(size: 10)
        let cachedAllocations = mockStoreWithAllocations.get("test_user")
        let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env",
                                 mockStoreWithAllocations, self.mockHttpClient)
        let emitter = EventEmitter(config, participant)
        
        let subscriptionKey = "search.weighting.distance.bubbles"
        let defaultValue: Double = 0.001
        
        let promise = Promise { resolver in
            resolver.fulfill(cachedAllocations)
        }
        
        let expect = expectation(description: "call back method key invalid")
        let applyFunction: (Double) -> Void = { value in
            XCTAssertEqual(defaultValue, value)
            XCTAssertNotEqual(value, 2.5)
            expect.fulfill()
        }
        
        let client = EvolvClientImpl(config, emitter, promise, mockAllocator, true, participant)
        client.subscribe(subscriptionKey, defaultValue, applyFunction)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testEmitEventWithScore() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig,
                                                                                actualConfig,
                                                                                mockExecutionQueue,
                                                                                mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
        let key = "testKey"
        let score = 1.3
        client.emitEvent(key, score)
        
        XCTAssertTrue(client.emitEventWithScoreWasCalled)
    }
    
    func testEmitEvent() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig,
                                                                                actualConfig,
                                                                                mockExecutionQueue,
                                                                                mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
        let key = "testKey"
        client.emitEvent(key)
        
        XCTAssertTrue(client.emitEventWasCalled)
    }
    
    func testConfirmEventSandBagged() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig,
                                                                                actualConfig,
                                                                                mockExecutionQueue,
                                                                                mockHttpClient,
                                                                                mockAllocationStore)
        
        XCTAssertEqual(mockAllocator.getAllocationStatus(), .fetching)
        
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
        client.confirm(allocator)
        
        XCTAssertTrue(allocator.sandbagConfirmationWasCalled)
    }
    
    func testConfirmEvent() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig,
                                                                                actualConfig,
                                                                                mockExecutionQueue,
                                                                                mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
        let emitter = EmitterMock(self.mockConfig, self.participant)
        client.confirm(emitter, allocations)
        allocator.allocationStatus = .retrieved
        
        XCTAssertEqual(allocator.allocationStatus, .retrieved)
        XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
    }
    
    func testContaminateEventSandBagged() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig,
                                                                                actualConfig,
                                                                                mockExecutionQueue,
                                                                                mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        allocator.allocationStatus = .fetching
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
        client.contaminate(allocator)
        
        XCTAssertEqual(allocator.allocationStatus, .fetching)
        XCTAssertTrue(allocator.sandbagContamationWasCalled)
    }
    
    func testContaminateEvent() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig,
                                                                                actualConfig,
                                                                                mockExecutionQueue,
                                                                                mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
        let emitter = EmitterMock(self.mockConfig, self.participant)
        client.contaminate(emitter, allocations)
        allocator.allocationStatus = .retrieved
        
        XCTAssertEqual(allocator.allocationStatus, .retrieved)
        XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
    }
    
    func testSubscribeNoPreviousAllocationsWithFetchingState() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                                mockExecutionQueue, mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        allocator.allocationStatus = .fetching
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
        
        let expectedTestValue: Double = 2.5
        let defaultValue: Double = 10.01
        
        func updateValue(value: Double) {
            self.testValue = value
        }
        
        client.subscribe("search.weighting.distance", defaultValue, updateValue)
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        self.testValue = 0.0
    }
    
    func testSubscribeNoPreviousAllocationsWithRetrievedState() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                                mockExecutionQueue, mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        allocator.allocationStatus = .retrieved
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
        
        let expectedTestValue: Double = 0.0
        let defaultValue: Double = 10.01
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        
        let expected: Double = 2.5
        func updateValue(value: Double) {
            self.testValue = value
        }
        
        client.subscribe("search.weighting.distance", defaultValue, updateValue)
        XCTAssertEqual(expected, self.testValue)
        self.testValue = 0.0
    }

    func testSubscribeNoPreviousAllocationsWithFailedState() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                                mockExecutionQueue, mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        allocator.allocationStatus = .failed
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
        
        let expectedTestValue: Double = 0.0
        let defaultValue: Double = 10.01
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        
        let expected: Double = 2.5
        func updateValue(value: Double) {
            self.testValue = value
        }
        
        client.subscribe("search.weighting.distance", defaultValue, updateValue)
        XCTAssertEqual(expected, self.testValue)
        self.testValue = 0.0
    }
    
    func testSubscribeNoPreviousAllocationsWithRetrievedStateThrowsError() {
        let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                                mockExecutionQueue, mockHttpClient,
                                                                                mockAllocationStore)
        let allocations = self.rawAllocations
        let promise = Promise { resolver in
            resolver.fulfill(allocations)
        }
        
        let allocator = AllocatorMock(mockConfig, self.participant)
        allocator.allocationStatus = .failed
        
        let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
        
        let expectedTestValue: Double = 0.0
        let defaultValue: Double = 10.01
        
        XCTAssertEqual(expectedTestValue, self.testValue)
        
        let expected: Double = 2.5
        func updateValue(value: Double) {
            self.testValue = value
        }
        
        client.subscribe("not.a.valid.key", defaultValue, updateValue)
        XCTAssertNotEqual(expected, self.testValue)
        self.testValue = 0.0
    }
    
}
