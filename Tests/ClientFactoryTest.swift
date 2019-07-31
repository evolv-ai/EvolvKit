//
//  EvolvClientTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import PromiseKit
@testable import EvolvKit

class ClientFactoryTest: XCTestCase {
    
    private let environmentId: String = "test_12345"
    private var mockHttpClient: EvolvHttpClient!
    private var mockAllocationStore: EvolvAllocationStore!
    private var mockExecutionQueue: EvolvExecutionQueue!
    private var mockConfig: EvolvConfig!
    
    override func setUp() {
        super.setUp()
        
        mockHttpClient = HttpClientMock()
        mockAllocationStore = AllocationStoreMock(testCase: self)
        mockExecutionQueue = ExecutionQueueMock()
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
    
    func createAllocationsUrl(config: EvolvConfig, participant: EvolvParticipant) -> URL {
        var components = URLComponents()
        components.scheme = config.httpScheme
        components.host = config.domain
        components.path = "/\(config.version)/\(config.environmentId)/allocations"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue, value: "\(participant.sessionId)")
        ]
        return components.url!
    }
    
    func testClientInit() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        var responsePromise = mockHttpClient.get(URL(string: anyString(length: 12))!)
        responsePromise = Promise { resolver in
            resolver.fulfill(TestData.rawAllocationsString)
        }
        
        XCTAssertNotNil(responsePromise)
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
        
        let client = EvolvClientFactory.createClient(config: mockConfig)
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
        XCTAssertNotNil(client)
    }
    
    private func anyString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func testClientInitSameUser() {
        let participant = EvolvParticipant.builder()
            .set(userId: "test_uid")
            .build()
        let mockClient = HttpClientMock()
        
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: mockConfig,
                                                                            actualConfig: actualConfig,
                                                                            mockExecutionQueue: mockExecutionQueue,
                                                                            mockHttpClient: mockClient,
                                                                            mockAllocationStore: mockAllocationStore)
        
        let previousAllocations = TestData.rawAllocations
        let previousUid = previousAllocations[0].userId
        
        mockAllocationStore.put(previousUid, previousAllocations)
        let cachedAllocations = mockAllocationStore.get(previousUid)
        
        XCTAssertEqual(cachedAllocations, previousAllocations)
        
        let client = EvolvClientFactory.createClient(config: mockConfig, participant: participant)
        
        XCTAssertNotNil(client)
    }
    
}
