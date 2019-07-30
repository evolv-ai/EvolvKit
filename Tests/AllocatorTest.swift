//
//  AllocatorTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class AllocatorTest: XCTestCase {
    
    private let environmentId: String = "test_12345"
    private var rawAllocations: EvolvRawAllocations {
        let data: [[String: Any]] = [
            [
                EvolvRawAllocations.Key.userId.rawValue: "test_uid",
                EvolvRawAllocations.Key.sessionId.rawValue: "test_sid",
                EvolvRawAllocations.Key.experimentId.rawValue: "test_eid",
                EvolvRawAllocations.Key.candidateId.rawValue: "test_cid",
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
        return EvolvConfig(httpScheme: actualConfig.httpScheme,
                           domain: actualConfig.domain,
                           version: actualConfig.version,
                           environmentId: actualConfig.environmentId,
                           evolvAllocationStore: mockAllocationStore,
                           httpClient: mockHttpClient)
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
            URLQueryItem(name: EvolvRawAllocations.Key.userId.rawValue, value: "\(participant.userId)")
        ]
        return components.url!
    }
    
    func createConfirmationUrl(config: EvolvConfig, rawAllocations: EvolvRawAllocations, participant: EvolvParticipant) -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocations.Key.userId.rawValue,
                         value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.sessionId.rawValue,
                         value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.experimentId.rawValue,
                         value: "\(rawAllocations[0][EvolvRawAllocations.Key.experimentId.rawValue].stringValue)"),
            URLQueryItem(name: EvolvRawAllocations.Key.candidateId.rawValue,
                         value: "\(rawAllocations[0][EvolvRawAllocations.Key.candidateId.rawValue].stringValue)"),
            URLQueryItem(name: EvolvRawAllocations.Key.type.rawValue,
                         value: "confirmation")
        ]
        return components.url!
    }
    
    func createContaminationUrl(config: EvolvConfig, rawAllocations: EvolvRawAllocations, participant: EvolvParticipant) -> URL {
        var components = createUrlComponents(config: config)
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocations.Key.userId.rawValue,
                         value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.sessionId.rawValue,
                         value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.experimentId.rawValue,
                         value: "\(rawAllocations[0][EvolvRawAllocations.Key.experimentId.rawValue].stringValue)"),
            URLQueryItem(name: EvolvRawAllocations.Key.candidateId.rawValue,
                         value: "\(rawAllocations[0][EvolvRawAllocations.Key.candidateId.rawValue].stringValue)"),
            URLQueryItem(name: EvolvRawAllocations.Key.type.rawValue,
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
        let nilAllocations: EvolvRawAllocations? = nil
        let emptyAllocations = EvolvRawAllocations()
        let allocations = self.rawAllocations
        
        XCTAssertFalse(EvolvAllocator.allocationsNotEmpty(nilAllocations))
        XCTAssertFalse(EvolvAllocator.allocationsNotEmpty(emptyAllocations))
        XCTAssertTrue(EvolvAllocator.allocationsNotEmpty(allocations))
    }
    
    func testResolveAllocationFailureWithAllocationsInStore() {
        let participant = EvolvParticipant.builder().build()
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let allocations = self.rawAllocations
        
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
        let allocations = self.rawAllocations
        
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
        let allocations = self.rawAllocations
        
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
        XCTAssertEqual(EvolvRawAllocations(), actualAllocations)
    }
    
    func testFetchAllocationsWithNoAllocationsInStore() {
        let participant = EvolvParticipant.builder().build()
        let rawAllocations = self.rawAllocations
        let allocationsEmpty = mockAllocationStore.get(participant.userId)
        let allocator = EvolvAllocator(config: mockConfig, participant: participant)
        let allocationsPromise = allocator.fetchAllocations()
        
        XCTAssertNotNil(allocationsPromise)
        XCTAssertNotEqual(rawAllocations, allocationsEmpty)
        XCTAssertEqual(allocationsEmpty, EvolvRawAllocations())
    }
    
    func testAllocationsReconciliation() {
        let participant = EvolvParticipant.builder().build()
        let allocations = self.rawAllocations
        let allocationsJson = self.rawAllocations
        
        mockAllocationStore.put(participant.userId, allocationsJson)
        
        let previous = mockAllocationStore.get(participant.userId)
        let reconciled = EvolvAllocations.reconcileAllocations(previousAllocations: previous, currentAllocations: allocations)
        
        XCTAssertEqual(allocations, reconciled)
    }
    
    func testAllocationsNotEmptyFunction() {
        let participant = EvolvParticipant.builder().build()
        let emptyAllocations = mockAllocationStore.get(participant.userId)
        let allocations = self.rawAllocations
        
        XCTAssertNotNil(emptyAllocations)
        XCTAssertTrue(emptyAllocations == EvolvRawAllocations())
        XCTAssertTrue(allocations != EvolvRawAllocations())
        XCTAssertFalse(emptyAllocations == allocations)
    }
    
}
