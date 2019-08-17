//
//  EventEmitterTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EvolvKit

class EventEmitterTest: XCTestCase {
    
    private let environmentId = "test_12345"
    private let type = "test"
    private let score = 10.0
    private let eid = "test_eid"
    private let cid = "test_cid"
    private var mockConfig: ConfigMock!
    private var mockExecutionQueue: ExecutionQueueMock!
    private var mockHttpClient: HttpClientMock!
    private var mockAllocationStore: DefaultEvolvAllocationStore!
    
    override func setUp() {
        super.setUp()
        
        mockExecutionQueue = ExecutionQueueMock()
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
    
    func createAllocationEventUrl(config: EvolvConfig, rawAllocation: EvolvRawAllocation, event: String, participant: EvolvParticipant) -> URL {
        //    let _ = "%s://%s/%s/%s/events?uid=%s&sid=%s&eid=%s&cid=%s&type=%s"
        var components = URLComponents()
        
        components.scheme = config.httpScheme
        components.host = config.domain
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue, value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.experimentId.stringValue, value: "\(rawAllocation.experimentId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.candidateId.stringValue, value: "\(rawAllocation.candidateId)"),
            URLQueryItem(name: "type", value: "\(event)")
        ]
        
        return components.url ?? URL(string: "")!
    }
    
    func createEventsUrl(config: EvolvConfig, type: String, score: Double, participant: EvolvParticipant) -> URL {
        //    let _ = "%s://%s/%s/%s/events?uid=%s&sid=%s&type=%s&score=%s"
        var components = URLComponents()
        
        components.scheme = config.httpScheme
        components.host = config.domain
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue, value: "\(participant.sessionId)"),
            URLQueryItem(name: "type", value: "\(type)"),
            URLQueryItem(name: "score", value: "\(String(score))")
        ]
        
        return components.url ?? URL(string: "")!
    }
    
    func testGetEventUrl() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        let participant = EvolvParticipant.builder().build()
        let emitter = EvolvEventEmitter(config: mockConfig, participant: participant)
        let url = emitter.createEventUrl(type: type, score: score)
        
        XCTAssertEqual(createEventsUrl(config: actualConfig, type: type, score: score, participant: participant), url)
    }
    
    func testGetEventUrlWithEidAndCid() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                actualConfig: actualConfig,
                                                                mockExecutionQueue: mockExecutionQueue,
                                                                mockHttpClient: mockHttpClient,
                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        let participant = EvolvParticipant.builder().build()
        
        let emitter = EvolvEventEmitter(config: mockConfig, participant: participant)
        let url = emitter.createEventUrl(type: type, experimentId: eid, candidateId: cid)
        let testUrl = createAllocationEventUrl(config: actualConfig, rawAllocation: allocations[0], event: type, participant: participant)
        
        XCTAssertEqual(testUrl, url)
    }
    
    func testSendAllocationEvents() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        
        let participant = EvolvParticipant.builder()
            .set(userId: "test_user")
            .set(sessionId: "test_session")
            .build()
        let emitter = EventEmitterMock(config: mockConfig, participant: participant)
        
        /// sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
        emitter.sendAllocationEvents(forKey: type, rawAllocations: allocations)
        
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    }
    
    func testContaminateEvent() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        
        let participant = EvolvParticipant.builder().build()
        let emitter = EventEmitterMock(config: mockConfig, participant: participant)
        
        /// emitter.contaminate => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
        emitter.contaminate(rawAllocations: allocations)
        
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    }
    
    func testConfirmEvent() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig,
                                                                                actualConfig: actualConfig,
                                                                                mockExecutionQueue: mockExecutionQueue,
                                                                                mockHttpClient: mockHttpClient,
                                                                                mockAllocationStore: mockAllocationStore)
        let allocations = TestData.rawAllocations
        
        let participant = EvolvParticipant.builder().build()
        let emitter = EventEmitterMock(config: mockConfig, participant: participant)
        
        /// emitter.confirm => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
        emitter.confirm(rawAllocations: allocations)
        
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    }
    
    func testGenericEvent() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let participant = EvolvParticipant.builder().build()
        let emitter = EventEmitterMock(config: actualConfig, participant: participant)
        
        emitter.emit(forKey: type)
        
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    }
    
    func testGenericEventWithScore() {
        let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
        let participant = EvolvParticipant.builder().build()
        let emitter = EventEmitterMock(config: actualConfig, participant: participant)
        
        emitter.emit(forKey: type, score: score)
        
        XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
    }
    
}
