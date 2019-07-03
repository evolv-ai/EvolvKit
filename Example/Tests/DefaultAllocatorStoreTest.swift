//
//  DefaultAllocatorStoreTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import EvolvKit

class DefaultAllocatorStoreTest: XCTestCase {
  
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  
  func testEmptyStoreRGetsEmptyJsonArray() {
    let store = DefaultAllocationStore(size: 10)
    
    XCTAssertNotNil(store.get(uid: "test_user"))
    XCTAssertEqual(0, store.get(uid: "test_user").count)
    XCTAssertEqual([JSON](), store.get(uid: "test_user"))
  }
  
  func testSetAndGetOnStore() {
    let store = DefaultAllocationStore(size: 10)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    store.put(uid: "test_user", allocations: allocations)
    let storedAllocations = store.get(uid: "test_user")
    
    XCTAssertNotNil(storedAllocations)
    XCTAssertNotEqual([JSON](), storedAllocations)
    XCTAssertEqual(allocations, storedAllocations)
  }
  
}
