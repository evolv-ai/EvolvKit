//
//  AllocatorTest.swift
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

class AllocatorTest: XCTestCase {
    
    private let environmentId: String = "test_12345"
    private var mockConfig: EvolvConfig!
    private var mockExecutionQueue: EvolvExecutionQueue!
    private var mockHttpClient: HttpClientMock!
    private var mockAllocationStore: EvolvAllocationStore!
    
    override func setUp() {
        super.setUp()
        
        mockExecutionQueue = EvolvExecutionQueue()
        mockHttpClient = HttpClientMock()
        mockAllocationStore = DefaultEvolvAllocationStore(size: 1)
        mockConfig = ConfigMock(httpScheme: "https",
                                domain: "test_domain",
                                version: "test_v",
                                environmentId: "test_eid",
                                evolvAllocationStore: mockAllocationStore,
                                httpClient: mockHttpClient)
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockHttpClient = nil
        mockAllocationStore = nil
        mockExecutionQueue = nil
        mockConfig = nil
    }
    
    func setUpMockedEvolvConfigWithMockedClient(mockedConfig: EvolvConfig,
                                                actualConfig: EvolvConfig,
                                                mockExecutionQueue: EvolvExecutionQueue,
                                                mockHttpClient: EvolvHttpClient,
                                                mockAllocationStore: EvolvAllocationStore) -> EvolvConfig {
        let config = EvolvConfig(httpScheme: actualConfig.httpScheme,
                                 domain: actualConfig.domain,
                                 version: actualConfig.version,
                                 environmentId: actualConfig.environmentId,
                                 evolvAllocationStore: mockAllocationStore,
                                 httpClient: mockHttpClient)
        config.set(logLevel: .error)
        return config
    }
    
    func createUrlComponents(config: EvolvConfig) -> URLComponents {
        var components = URLComponents()
        components.scheme = config.httpScheme
        components.host = config.domain
        return components
    }
    
    func createAllocationsUrl(config: EvolvConfig, participant: EvolvParticipant) -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/allocations"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)")
        ]
        return components.url!
    }
    
    func createConfirmationUrl(config: EvolvConfig, rawAllocations: [EvolvRawAllocation], participant: EvolvParticipant) -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue,
                         value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue,
                         value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.experimentId.stringValue,
                         value: "\(rawAllocations[0].experimentId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.candidateId.stringValue,
                         value: "\(rawAllocations[0].candidateId)"),
            URLQueryItem(name: "type",
                         value: "confirmation")
        ]
        return components.url!
    }
    
    func createContaminationUrl(config: EvolvConfig, rawAllocations: [EvolvRawAllocation], participant: EvolvParticipant) -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue,
                         value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue,
                         value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.experimentId.stringValue,
                         value: "\(rawAllocations[0].experimentId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.candidateId.stringValue,
                         value: "\(rawAllocations[0].candidateId)"),
            URLQueryItem(name: "type",
                         value: "contamination")
        ]
        return components.url!
    }
    
    func testCreateAllocationsUrl() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        let participant = EvolvParticipant.builder().build()
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        let actualUrl = allocator.createAllocationsUrl()
        let expectedUrl = createAllocationsUrl(config: actualConfig, participant: participant)
        
        XCTAssertEqual(expectedUrl, actualUrl)
    }
    
    func testAllocationsNotEmpty() {
        let nilAllocations: [EvolvRawAllocation]? = nil
        let emptyAllocations = [EvolvRawAllocation]()
        let allocations = TestData.rawAllocations
        
        XCTAssertFalse(EvolvAllocator.allocationsNotEmpty(nilAllocations))
        XCTAssertFalse(EvolvAllocator.allocationsNotEmpty(emptyAllocations))
        XCTAssertTrue(EvolvAllocator.allocationsNotEmpty(allocations))
    }
    
    func testResolveAllocationFailureWithAllocationsInStore() {
        let participant = EvolvParticipant.builder().build()
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let allocations = TestData.rawAllocations
        
        mockAllocationStore.put(participant.userId, allocations)
        
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        let actualAllocations = allocator.resolveAllocationsFailure()
        
        let exp = expectation(description: "Execute All With Values From Allocations")
        try? mockExecutionQueue.executeAllWithValues(from: allocations)
        exp.fulfill()
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(exp.expectedFulfillmentCount, 1)
        XCTAssertEqual(.retrieved, allocator.getAllocationStatus())
        XCTAssertEqual(allocations, actualAllocations)
    }
    
    func testResolveAllocationFailureWithAllocationsInStoreWithSandbaggedConfirmation() {
        let participant = EvolvParticipant.builder().build()
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let allocations = TestData.rawAllocations
        
        mockAllocationStore.put(participant.userId, allocations)
        
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        
        allocator.sandbagConfirmation()
        let actualAllocations = allocator.resolveAllocationsFailure()
        
        let exp = expectation(description: "Create Confirmation Url, Get Allocations From Store")
        mockHttpClient.get(createConfirmationUrl(config: actualConfig, rawAllocations: allocations, participant: participant))
        exp.fulfill()
        waitForExpectations(timeout: 3)
        
        let exp2 = expectation(description: "Execute All With Values From Allocations")
        try? mockExecutionQueue.executeAllWithValues(from: allocations)
        exp2.fulfill()
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(exp.expectedFulfillmentCount, 1)
        XCTAssertEqual(exp2.expectedFulfillmentCount, 1)
        XCTAssertEqual(.retrieved, allocator.getAllocationStatus())
        XCTAssertEqual(allocations, actualAllocations)
    }
    
    func testResolveAllocationFailureWithAllocationsInStoreWithSandbaggedContamination() {
        let participant = EvolvParticipant.builder().build()
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let allocations = TestData.rawAllocations
        
        mockAllocationStore.put(participant.userId, allocations)
        
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        allocator.sandbagContamination()
        let actualAllocations = allocator.resolveAllocationsFailure()
        
        let exp = expectation(description: "Create Contaminatin Url, Get Allocations From Store")
        mockHttpClient.get(createConfirmationUrl(config: actualConfig, rawAllocations: allocations, participant: participant))
        exp.fulfill()
        waitForExpectations(timeout: 3)
        
        let exp2 = expectation(description: "Execute All With Values From Allocations")
        try? mockExecutionQueue.executeAllWithValues(from: allocations)
        exp2.fulfill()
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(exp.expectedFulfillmentCount, 1)
        XCTAssertEqual(exp2.expectedFulfillmentCount, 1)
        XCTAssertEqual(.retrieved, allocator.getAllocationStatus())
        XCTAssertEqual(allocations, actualAllocations)
    }
    
    func testResolveAllocationFailureWithNoAllocationsInStore() {
        let participant = EvolvParticipant.builder().build()
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let allocations = mockAllocationStore.get(participant.userId)
        
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        allocator.sandbagContamination()
        
        let actualAllocations = allocator.resolveAllocationsFailure()
        
        let exp = expectation(description: "Execute All With Values From Allocations")
        try? mockExecutionQueue.executeAllWithValues(from: allocations)
        exp.fulfill()
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(exp.expectedFulfillmentCount, 1)
        XCTAssertEqual(.failed, allocator.getAllocationStatus())
        XCTAssertEqual([EvolvRawAllocation](), actualAllocations)
    }
    
    func testFetchAllocationsWithNoAllocationsInStore() {
        let participant = EvolvParticipant.builder().build()
        let rawAllocations = TestData.rawAllocations
        let allocationsEmpty = mockAllocationStore.get(participant.userId)
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        let allocationsPromise = allocator.fetchAllocations()
        
        XCTAssertNotNil(allocationsPromise)
        XCTAssertNotEqual(rawAllocations, allocationsEmpty)
        XCTAssertEqual(allocationsEmpty, [EvolvRawAllocation]())
    }
    
    func testAllocationsReconciliation() {
        let participant = EvolvParticipant.builder().build()
        let allocations = TestData.rawAllocations
        let allocationsJson = TestData.rawAllocations
        
        mockAllocationStore.put(participant.userId, allocationsJson)
        
        let previous = mockAllocationStore.get(participant.userId)
        let reconciled = EvolvAllocations.reconcileAllocations(previousAllocations: previous, currentAllocations: allocations)
        
        XCTAssertEqual(allocations, reconciled)
    }
    
    func testAllocationsNotEmptyFunction() {
        let participant = EvolvParticipant.builder().build()
        let emptyAllocations = mockAllocationStore.get(participant.userId)
        let allocations = TestData.rawAllocations
        
        XCTAssertNotNil(emptyAllocations)
        XCTAssertTrue(emptyAllocations == [EvolvRawAllocation]())
        XCTAssertTrue(allocations != [EvolvRawAllocation]())
        XCTAssertFalse(emptyAllocations == allocations)
    }
    
}
