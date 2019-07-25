//
//  EventEmitterTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import EvolvKit

class EventEmitterTest: XCTestCase {
  
  private let environmentId = "test_12345"
  private let type = "test"
  private let score = 10.0
  private let eid = "test_eid"
  private let cid = "test_cid"
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
  
  private var mockConfig: ConfigMock!
  private var mockExecutionQueue: ExecutionQueueMock!
  private var mockHttpClient: HttpClientMock!
  private var mockAllocationStore: DefaultAllocationStore!
  
  override func setUp() {
    super.setUp()
    
    mockExecutionQueue = ExecutionQueueMock()
    mockHttpClient = HttpClientMock()
    mockAllocationStore = DefaultAllocationStore(size: 1)
    mockConfig = ConfigMock("https", "test_domain", "test_v", "test_eid", mockAllocationStore, mockHttpClient)
  }
  
  override func tearDown() {
    super.tearDown()
    
    if mockHttpClient != nil {
        mockHttpClient = nil
    }
    if mockAllocationStore != nil {
        mockAllocationStore = nil
    }
    if mockExecutionQueue != nil {
        mockExecutionQueue = nil
    }
    if mockConfig != nil {
        mockConfig = nil
    }
  }
  
  func setUpMockedEvolvConfigWithMockedClient(_ mockedConfig: EvolvConfig, _ actualConfig: EvolvConfig,
                                              _ mockExecutionQueue: ExecutionQueue, _ mockHttpClient: HttpProtocol,
                                              _ mockAllocationStore: AllocationStoreProtocol) -> EvolvConfig {
    
    return EvolvConfig(actualConfig.getHttpScheme(), actualConfig.getDomain(),
                       actualConfig.getVersion(), actualConfig.getEnvironmentId(),
                       mockAllocationStore, mockHttpClient)
  }
  
  func createAllocationEventUrl(config: EvolvConfig, allocation: JSON, event: String, participant: EvolvParticipant) -> URL {
//    let _ = "%s://%s/%s/%s/events?uid=%s&sid=%s&eid=%s&cid=%s&type=%s"
    var components = URLComponents()
    
    let eid = allocation["eid"].rawString()!
    let cid = allocation["cid"].rawString()!
    
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(eid)"),
      URLQueryItem(name: "cid", value: "\(cid)"),
      URLQueryItem(name: "type", value: "\(event)")
    ]
    
    return components.url ?? URL(string: "")!
  }
  
  func createEventsUrl(config: EvolvConfig, type: String, score: Double, participant: EvolvParticipant) -> URL {
//    let _ = "%s://%s/%s/%s/events?uid=%s&sid=%s&type=%s&score=%s"
    var components = URLComponents()
    
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "type", value: "\(type)"),
      URLQueryItem(name: "score", value: "\(String(score))")
    ]
    
    return components.url ?? URL(string: "")!
  }
  
  func testGetEventUrl() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                            mockExecutionQueue, mockHttpClient,
                                                            mockAllocationStore)
    
    let participant = EvolvParticipant.builder().build()
    let emitter = EventEmitter(config: mockConfig, participant: participant)
    let url = emitter.createEventUrl(type: type, score: score)
    
    XCTAssertEqual(createEventsUrl(config: actualConfig, type: type, score: score, participant: participant), url)
  }
  
  func testGetEventUrlWithEidAndCid() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                            mockExecutionQueue, mockHttpClient,
                                                            mockAllocationStore)
    
    let allocations = self.rawAllocations
    let participant = EvolvParticipant.builder().build()
    
    let emitter = EventEmitter(config: mockConfig, participant: participant)
    let url = emitter.createEventUrl(type: type, experimentId: eid, candidateId: cid)
    let testUrl = createAllocationEventUrl(config: actualConfig, allocation: allocations[0], event: type, participant: participant)
    
    XCTAssertEqual(testUrl, url)
  }
  
  func testSendAllocationEvents() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue,
                                                                             mockHttpClient, mockAllocationStore)
    let allocations = self.rawAllocations
    
    let participant = EvolvParticipant.builder().setUserId(userId: "test_user").setSessionId(sessionId: "test_session").build()
    let emitter = EmitterMock(config: mockConfig, participant: participant)
    
    /// sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
    emitter.sendAllocationEvents(type, allocations)
    
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
  }
  
  func testContaminateEvent() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue,
                                                                            mockHttpClient, mockAllocationStore)
    let allocations = self.rawAllocations
    
    let participant = EvolvParticipant.builder().build()
    let emitter = EmitterMock(config: mockConfig, participant: participant)
    
    /// emitter.contaminate => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
    emitter.contaminate(allocations: allocations)
    
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
  }
  
  func testConfirmEvent() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig, mockExecutionQueue,
                                                                            mockHttpClient, mockAllocationStore)
    let allocations = self.rawAllocations
    
    let participant = EvolvParticipant.builder().build()
    let emitter = EmitterMock(config: mockConfig, participant: participant)
    
    /// emitter.confirm => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
    emitter.confirm(allocations: allocations)
    
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
  }
  
  func testGenericEvent() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let participant = EvolvParticipant.builder().build()
    let emitter = EmitterMock(config: actualConfig, participant: participant)
    
    emitter.emit(type)
    
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
  }
  
  func testGenericEventWithScore() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let participant = EvolvParticipant.builder().build()
    let emitter = EmitterMock(config: actualConfig, participant: participant)
    
    emitter.emit(type, score)
    
    XCTAssertTrue(HttpClientMock.httpClientSendEventsWasCalled)
  }
}
