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
    
    private var rawAllocations: EvolvRawAllocations {
        let data: [[String: Any]] = [
            [
                EvolvRawAllocations.Key.userId.rawValue: "test_uid",
                EvolvRawAllocations.Key.sessionId.rawValue: "test_sid",
                EvolvRawAllocations.Key.experimentId.rawValue: "test_eid",
                EvolvRawAllocations.Key.candidateId.rawValue: "test_cid",
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
    
    func testEmptyStoreRGetsEmptyJsonArray() {
        let store = DefaultEvolvAllocationStore(size: 10)
        
        XCTAssertNotNil(store.get("test_user"))
        XCTAssertEqual(0, store.get("test_user").count)
        XCTAssertEqual(EvolvRawAllocations(), store.get("test_user"))
    }
    
    func testSetAndGetOnStore() {
        let store = DefaultEvolvAllocationStore(size: 10)
        let allocations = self.rawAllocations
        store.put("test_user", allocations)
        let storedAllocations = store.get("test_user")
        
        XCTAssertNotNil(storedAllocations)
        XCTAssertNotEqual(EvolvRawAllocations(), storedAllocations)
        XCTAssertEqual(allocations, storedAllocations)
    }
    
}
