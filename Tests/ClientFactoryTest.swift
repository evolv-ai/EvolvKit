//
//  EvolvClientTest.swift
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
        responsePromise = AnyPromise(Promise { resolver in
            resolver.fulfill(TestData.rawJSONString(fromFile: "rawAllocationsString"))
        })
        
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
