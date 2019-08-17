//
//  LruCacheTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
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
