//
//  Mocks.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Alamofire
import PromiseKit
@testable import EvolvKit

class Mocks: XCTestCase {}

class AllocationStoreMockWithAllocations: EvolvAllocationStore {
    
    public var cache: LRUCache
    
    public init(size: Int) {
        self.cache = LRUCache(size)
        let allocationsForMockStore = TestData.rawAllocations
        cache.putEntry("test_user", allocationsForMockStore)
    }
    
    public func get(_ uid: String) -> [EvolvRawAllocation] {
        return cache.getEntry(uid)
    }
    
    public func put(_ uid: String, _ allocations: [EvolvRawAllocation]) {
        cache.putEntry(uid, allocations)
    }
    
}

class AllocationStoreMock: EvolvAllocationStore {
    
    let testCase: XCTestCase
    var mockedCache = DefaultEvolvAllocationStore(size: 10)
    
    init (testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    var expectGetExpectation: XCTestExpectation?
    var expectPutExpectation: XCTestExpectation?
    
    private var mockedGet: (String) -> [EvolvRawAllocation] = { _ in
        return TestData.rawAllocations
    }
    
    private var mockedPut: (String, [EvolvRawAllocation]) -> Void = { _, _  in
        let rawAllocation = TestData.rawAllocations
        let allocations = TestData.rawAllocations
        DefaultEvolvAllocationStore(size: 10).put("test_user", allocations)
    }
    
    @discardableResult
    func expectGet(_ mocked: @escaping (_ uid: String) -> [EvolvRawAllocation]) -> XCTestExpectation {
        self.expectGetExpectation = self.testCase.expectation(description: "expect get")
        self.mockedGet = mocked
        return expectGetExpectation!
    }
    
    func expectPut(_ mocked: @escaping (_ uid: String, _ allocations: [EvolvRawAllocation]) -> Void) -> XCTestExpectation {
        self.expectPutExpectation = self.testCase.expectation(description: "expect put")
        self.mockedPut = mocked
        return expectPutExpectation!
    }
    
    /// conform to protocol
    @discardableResult
    func get(_ uid: String) -> [EvolvRawAllocation] {
        self.expectGetExpectation?.fulfill()
        return mockedGet(uid)
    }
    
    func put(_ uid: String, _ allocations: [EvolvRawAllocation]) {
        self.expectGetExpectation?.fulfill()
        return mockedPut(uid, allocations)
    }
    
}

class ClientFactoryMock: EvolvClientFactory {}

class HttpClientMock: EvolvHttpClient {
    
    public static var httpClientSendEventsWasCalled = false
    
    @discardableResult
    func get(_ url: URL) -> Promise<String> {
        HttpClientMock.httpClientSendEventsWasCalled = true
        return Promise<String> { resolver -> Void in
            
            Alamofire.request(url)
                .validate()
                .responseString { response in
                    switch response.result {
                    case .success:
                        if let responseString = response.result.value {
                            
                            resolver.fulfill(responseString)
                        }
                    case .failure(let error):
                        
                        resolver.reject(error)
                    }
            }
        }
    }
    
    func sendEvents(_ url: URL) {
        HttpClientMock.httpClientSendEventsWasCalled = true
        let headers = [
            "Content-Type": "application/json",
            "Host": "participants.evolv.ai"
        ]
        
        Alamofire.request(url,
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default ,
                          headers: headers).responseData { dataResponse in
                            if dataResponse.response?.statusCode == 202 {
                                print("All good over here!")
                            } else {
                                print("Something really bad happened")
                            }
        }
    }
    
}

class ClientMock: DefaultEvolvClient {
    
    var emitEventWasCalled = false
    var emitEventWithScoreWasCalled = false
    let mockHttpClient = DefaultEvolvHttpClient()
    
    override public func emitEvent(forKey key: String) {
        emitEventWasCalled = true
    }
    
    override public func emitEvent(forKey key: String, score: Double) {
        emitEventWithScoreWasCalled = true
    }
    
    public func confirm(_ allocator: AllocatorMock) {
        allocator.sandbagConfirmation()
    }
    
    public func confirm(_ eventEmitter: EventEmitterMock, _ allocations: [EvolvRawAllocation]) {
        eventEmitter.confirm(rawAllocations: allocations)
    }
    
    public func contaminate(_ allocator: AllocatorMock) {
        allocator.sandbagContamination()
    }
    
    public func contaminate(_ eventEmitter: EventEmitterMock, _ allocations: [EvolvRawAllocation]) {
        eventEmitter.confirm(rawAllocations: allocations)
    }
    
}

class AllocatorMock: EvolvAllocator {
    
    var sandbagConfirmationWasCalled = false
    var sandbagContamationWasCalled = false
    
    var config: EvolvConfig
    var participant: EvolvParticipant
    
    var allocationStatus: AllocationStatus
    
    override init(config: EvolvConfig, participant: EvolvParticipant) {
        self.config = config
        self.participant = participant
        self.allocationStatus = .fetching
        
        super.init(config: config, participant: participant)
    }
    
    override func sandbagConfirmation() {
        self.allocationStatus = .retrieved
        sandbagConfirmationWasCalled = true
    }
    
    override func sandbagContamination() {
        sandbagContamationWasCalled = true
    }
    
}

class EventEmitterMock: EvolvEventEmitter {
    
    let httpClientMock = HttpClientMock()
    var confirmWithAllocationsWasCalled = false
    var contaminateWithAllocationsWasCalled = false
    
    override func sendAllocationEvents(forKey key: String, rawAllocations allocations: [EvolvRawAllocation]) {
        let eid = allocations[0].experimentId
        let cid = allocations[0].candidateId
        
        guard let url = createEventUrl(type: key, experimentId: eid, candidateId: cid) else {
            return
        }
        
        makeEventRequest(url)
    }
    
    private func makeEventRequest(_ url: URL) {
        httpClientMock.sendEvents(url)
    }
    
    /// emitter.contaminate => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
    override public func contaminate(rawAllocations allocations: [EvolvRawAllocation]) {
        let testKey = "test_key"
        sendAllocationEvents(forKey: testKey, rawAllocations: allocations)
        contaminateWithAllocationsWasCalled = true
    }
    
    /// emitter.confirm => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
    override public func confirm(rawAllocations allocations: [EvolvRawAllocation]) {
        let testKey = "test_key"
        sendAllocationEvents(forKey: testKey, rawAllocations: allocations)
        confirmWithAllocationsWasCalled = true
    }
    
    override public func emit(forKey key: String) {
        guard let url = createEventUrl(type: key, score: 1.0) else {
            return
        }
        
        makeEventRequest(url)
    }
    
    override public func emit(forKey key: String, score: Double) {
        guard let url = createEventUrl(type: key, score: score) else {
            return
        }
        
        makeEventRequest(url)
    }
    
}

class ExecutionQueueMock: EvolvExecutionQueue {
    
    var executeValuesFromAllocationsWasCalled = false
    var executeWithDefaultsWasCalled = false
    private var queue: [EvolvExecutable] = []
    
    override var count: Int {
        return queue.count
    }
    
    override func enqueue<T>(_ execution: EvolvExecution<T>) {
        queue.insert(execution, at: 0)
    }
    
    override func executeAllWithValues(from allocations: [EvolvRawAllocation]) {
        executeValuesFromAllocationsWasCalled = true
        queue.removeAll()
    }
    
    override func executeAllWithValuesFromDefaults() {
        executeWithDefaultsWasCalled = true
        queue.removeAll()
    }
    
}

class ExecutionMock<T>: EvolvExecution<T> {
    override func executeWithDefault() {}
    override func execute(with rawAllocations: [EvolvRawAllocation]) throws {}
}

class ConfigMock: EvolvConfig {}
