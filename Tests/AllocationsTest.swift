//
//  AllocationsTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class AllocationsTest: XCTestCase {
    
    public static var rawAllocations: [JSON] {
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
    private var rawMultiAllocations: [JSON] {
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
            ],
            [
                "uid": "test_uid",
                "sid": "test_sid",
                "eid": "test_eid_2",
                "cid": "test_cid_2",
                "genome": [
                    "best": [
                        "baked": [
                            "cookie": true,
                            "cake": false
                        ]
                    ],
                    "utensils": [
                        "knives": [
                            "drawer": [
                                "butcher",
                                "paring"
                            ]
                        ],
                        "spoons": [
                            "wooden": "oak",
                            "metal": "steel"
                        ]
                    ],
                    "measure": [
                        "cups": 2.0
                    ]
                ],
                "excluded": false
            ]
        ]
        
        return JSON(data).arrayValue
    }
    private var rawMultiAllocationsWithDups: [JSON] {
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
            ],
            [
                "uid": "test_uid",
                "sid": "test_sid",
                "eid": "test_eid_2",
                "cid": "test_cid_2",
                "genome": [
                    "best": [
                        "baked": [
                            "cookie": true,
                            "cake": false
                        ]
                    ],
                    "utensils": [
                        "knives": [
                            "drawer": [
                                "butcher",
                                "paring"
                            ]
                        ],
                        "spoons": [
                            "wooden": "oak",
                            "metal": "steel"
                        ]
                    ],
                    "algorithms": [
                        "feature_importance": true
                    ]
                ],
                "excluded": false
            ]
        ]
        
        return JSON(data).arrayValue
    }
    
    func testGetValueFromAllocationGenome() {
        do {
            let participant = EvolvParticipant.builder().build()
            let allocations = Allocations(AllocationsTest.rawAllocations)
            let defaultBool: Bool = true
            let defaultDouble: Double = 10.0
            let featureImportance = try allocations.getValueFromAllocations("algorithms.feature_importance",
                                                                            defaultBool, participant)
            let weightingDistance = try allocations.getValueFromAllocations("search.weighting.distance",
                                                                            defaultDouble, participant)
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetValueFromMultiAllocationGenome() {
        do {
            let participant: EvolvParticipant = EvolvParticipant.builder().build()
            let allocations = Allocations(AllocationsTest.rawAllocations)
            let defaultBool: Bool = true
            let defaultDouble: Double = 10.0
            let featureImportance = try allocations.getValueFromAllocations("algorithms.feature_importance",
                                                                            defaultBool, participant)
            let weightingDistance = try allocations.getValueFromAllocations("search.weighting.distance",
                                                                            defaultDouble, participant)
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetValueFromMultiAllocationWithDupsGenome() {
        do {
            let participant: EvolvParticipant = EvolvParticipant.builder().build()
            let allocations = Allocations(self.rawMultiAllocations)
            let defaultBool: Bool = true
            let defaultDouble: Double = 10.0
            let featureImportance = try allocations.getValueFromAllocations("algorithms.feature_importance",
                                                                            defaultBool, participant)
            let weightingDistance = try allocations.getValueFromAllocations("search.weighting.distance",
                                                                            defaultDouble, participant)
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetActiveExperiments () {
        let allocations = Allocations(self.rawMultiAllocationsWithDups)
        let activeExperiments: Set<String> = allocations.getActiveExperiments()
        var expected: Set<String> = Set()
        expected.update(with: "test_eid")
        expected.update(with: "test_eid_2")
        XCTAssertEqual(expected, activeExperiments)
    }
    
}
