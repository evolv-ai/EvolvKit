//
//  LruCacheTest.swift
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

class LruCacheTest: XCTestCase {
    
    func testGetEntryEmptyCache() {
        let testCacheSize = 10
        let testKey = "test_key"
        
        let cache = LRUCache(testCacheSize)
        let entry = cache.getEntry(testKey)
        
        XCTAssertNotNil(entry)
        XCTAssertTrue(entry.isEmpty)
    }
    
    func testGetEntry() {
        let testCacheSize = 10
        let testKey = "test_key"
        let testEntry = TestData.rawAllocations
        
        let cache = LRUCache(testCacheSize)
        cache.putEntry(testKey, testEntry)
        let entry = cache.getEntry(testKey)
        
        XCTAssertNotNil(entry)
        XCTAssertFalse(entry.isEmpty)
        XCTAssertEqual(testEntry, entry)
    }
    
    func testEvictEntry() {
        let testCacheSize = 3
        let keyOne = "key_one"
        let keyTwo = "key_two"
        let keyThree = "Key_three"
        let keyFour = "key_four"
        
        let testEntry = TestData.rawAllocations
        
        let cache = LRUCache(testCacheSize)
        
        cache.putEntry(keyOne, testEntry)
        cache.putEntry(keyTwo, testEntry)
        cache.putEntry(keyThree, testEntry)
        
        let entryOne = cache.getEntry(keyOne)
        let entryTwo = cache.getEntry(keyTwo)
        let entryThree = cache.getEntry(keyThree)
        
        cache.putEntry(keyFour, testEntry)
        
        let evictedEntry = cache.getEntry(keyOne)
        
        XCTAssertEqual(testEntry, entryOne)
        XCTAssertEqual(testEntry, entryTwo)
        XCTAssertEqual(testEntry, entryThree)
        XCTAssertTrue(evictedEntry.isEmpty)
    }
    
    func testPutEntryTwice() {
        let testCacheSize = 10
        let testKey = "test_key"
        let testEntry = TestData.rawAllocations
        
        let cache = LRUCache(testCacheSize)
        cache.putEntry(testKey, testEntry)
        cache.putEntry(testKey, testEntry)
        let entry = cache.getEntry(testKey)
        
        XCTAssertNotNil(entry)
        XCTAssertFalse(entry.isEmpty)
        XCTAssertEqual(testEntry, entry)
    }
    
}
