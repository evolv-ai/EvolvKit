//
//  DefaultAllocatorStoreTest.swift
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
