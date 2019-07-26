//
//  Mocks.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class Mocks: XCTestCase {}

class AllocationStoreMockWithAllocations: AllocationStoreProtocol {
  public var cache: LRUCache
  
  public init(size: Int) {
    self.cache = LRUCache(size)
    let allocationsForMockStore = AllocationsTest.rawAllocations
    cache.putEntry("test_user", allocationsForMockStore)
  }
  public func get(_ uid: String) -> [JSON] {
    return cache.getEntry(uid)
  }
  
  public func put(_ uid: String, _ allocations: [JSON]) {
    cache.putEntry(uid, allocations)
  }
}

class AllocationStoreMock: AllocationStoreProtocol {
  
  let testCase: XCTestCase
  var mockedCache = DefaultAllocationStore(size: 10)

  init (testCase: XCTestCase) {
    self.testCase = testCase
  }
  
  var expectGetExpectation: XCTestExpectation?
  var expectPutExpectation: XCTestExpectation?
  
  private var mockedGet: (String) -> [JSON] = { _ in
    return AllocationsTest.rawAllocations
  }
  
  private var mockedPut: (String, [JSON]) -> Void = { _, _  in
    let rawAllocation = AllocationsTest.rawAllocations
    let allocations = AllocationsTest.rawAllocations
    DefaultAllocationStore(size: 10).put("test_user", allocations)
  }
  
  @discardableResult
  func expectGet(_ mocked: @escaping (_ uid: String) -> [JSON]) -> XCTestExpectation {
    self.expectGetExpectation = self.testCase.expectation(description: "expect get")
    self.mockedGet = mocked
    return expectGetExpectation!
  }

  func expectPut(_ mocked: @escaping (_ uid: String, _ allocations: [JSON]) -> Void) -> XCTestExpectation {
    self.expectPutExpectation = self.testCase.expectation(description: "expect put")
    self.mockedPut = mocked
    return expectPutExpectation!
  }
  
  /// conform to protocol
  @discardableResult
  func get(_ uid: String) -> [JSON] {
    self.expectGetExpectation?.fulfill()
    return mockedGet(uid)
  }

  func put(_ uid: String, _ allocations: [JSON]) {
    self.expectGetExpectation?.fulfill()
    return mockedPut(uid, allocations)
  }
}

class ClientFactoryMock: EvolvClientFactory {
  
}

class HttpClientMock: HttpProtocol {
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

class ClientImplMock: EvolvClientImpl {
  var emitEventWasCalled = false
  var emitEventWithScoreWasCalled = false
  let mockHttpClient = EvolvHttpClient()
  
  override public func emitEvent(_ key: String) {
    emitEventWasCalled = true
  }
  
  override public func emitEvent(_ key: String, _ score: Double) {
    emitEventWithScoreWasCalled = true
  }
  
  public func confirm(_ allocator: AllocatorMock) {
    allocator.sandbagConfirmation()
  }
  
  public func confirm(_ eventEmitter: EmitterMock, _ allocations: [JSON]) {
    eventEmitter.confirm(allocations)
  }
  
  public func contaminate(_ allocator: AllocatorMock) {
    allocator.sandbagContamination()
  }
  
  public func contaminate(_ eventEmitter: EmitterMock, _ allocations: [JSON]) {
    eventEmitter.confirm(allocations)
  }

}

class AllocatorMock: Allocator {
  
  var sandbagConfirmationWasCalled = false
  var sandbagContamationWasCalled = false
    
  var config: EvolvConfig
  var participant: EvolvParticipant
    
  var allocationStatus: AllocationStatus
  
  override init(_ config: EvolvConfig, _ participant: EvolvParticipant) {
    self.config = config
    self.participant = participant
    self.allocationStatus = .fetching
    
    super.init(config, participant)
  }
  
  override func sandbagConfirmation() {
    self.allocationStatus = .retrieved
    sandbagConfirmationWasCalled = true
  }
  
  override func sandbagContamination() {
    sandbagContamationWasCalled = true
  }
}

class EmitterMock: EventEmitter {
  
  let httpClientMock = HttpClientMock()
  var confirmWithAllocationsWasCalled = false
  var contaminateWithAllocationsWasCalled = false
  
  override func sendAllocationEvents(_ key: String, _ allocations: [JSON]) {
    let eid = allocations[0]["eid"].rawString()!
    let cid = allocations[0]["cid"].rawString()!
    let url = createEventUrl(key, eid, cid)
    makeEventRequest(url)
  }
  
  private func makeEventRequest(_ url: URL) {
    _ = httpClientMock.sendEvents(url)
  }
  
  /// emitter.contaminate => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
  override public func contaminate(_ allocations: [JSON]) {
    let testKey = "test_key"
    sendAllocationEvents(testKey, allocations)
    contaminateWithAllocationsWasCalled = true
  }
  
  /// emitter.confirm => sendAllocationEvents => makeEventRequest => httpClient.sendEvents()
  override public func confirm(_ allocations: [JSON]) {
    let testKey = "test_key"
    sendAllocationEvents(testKey, allocations)
    confirmWithAllocationsWasCalled = true
  }
  
  override public func emit(_ key: String) {
    let url: URL = createEventUrl(key, 1.0)
    self.makeEventRequest(url)
  }
  
  override public func emit(_ key: String, _ score: Double) {
    let url: URL = createEventUrl(key, score)
    self.makeEventRequest(url)
  }
  
}

class ExecutionQueueMock: ExecutionQueue {
  var executeValuesFromAllocationsWasCalled = false
  var executeWithDefaultsWasCalled = false
  
  override func executeAllWithValuesFromAllocations(_ allocations: [JSON]) {
    self.count -= 1
    executeValuesFromAllocationsWasCalled = true
  }
  
  override func executeAllWithValuesFromDefaults() {
    self.count -= 1
    executeWithDefaultsWasCalled = true
  }
}

class ExecutionMock<T>: Execution<T> {
  
  override func executeWithDefault() {}
  
  override func executeWithAllocation(_ rawAllocations: [JSON]) throws {}
}

class ConfigMock: EvolvConfig { }

class ClientHttpMock: HttpProtocol {
  func get(_ url: URL) -> Promise<String> {
    fatalError()
  }
  
  func sendEvents(_ url: URL) {
    fatalError()
  }
}
