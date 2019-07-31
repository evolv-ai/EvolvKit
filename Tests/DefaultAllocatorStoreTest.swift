//
//  DefaultAllocatorStoreTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import EvolvKit

class DefaultAllocatorStoreTest: XCTestCase {
    
    func testEmptyStoreRGetsEmptyJsonArray() {
        let store = DefaultEvolvAllocationStore(size: 10)
        
        XCTAssertNotNil(store.get("test_user"))
        XCTAssertEqual(0, store.get("test_user").count)
        XCTAssertEqual([EvolvRawAllocation](), store.get("test_user"))
    }
    
    func testSetAndGetOnStore() {
        let store = DefaultEvolvAllocationStore(size: 10)
        let allocations = TestData.rawAllocations
        store.put("test_user", allocations)
        let storedAllocations = store.get("test_user")
        
        XCTAssertNotNil(storedAllocations)
        XCTAssertNotEqual([EvolvRawAllocation](), storedAllocations)
        XCTAssertEqual(allocations, storedAllocations)
    }
    
}
