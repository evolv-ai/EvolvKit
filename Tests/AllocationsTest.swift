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
    
    public static var rawAllocations: EvolvRawAllocations {
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
    private var rawMultiAllocations: EvolvRawAllocations {
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
            ],
            [
                EvolvRawAllocations.Key.userId.rawValue: "test_uid",
                EvolvRawAllocations.Key.sessionId.rawValue: "test_sid",
                EvolvRawAllocations.Key.experimentId.rawValue: "test_eid_2",
                EvolvRawAllocations.Key.candidateId.rawValue: "test_cid_2",
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
    private var rawMultiAllocationsWithDups: EvolvRawAllocations {
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
            ],
            [
                EvolvRawAllocations.Key.userId.rawValue: "test_uid",
                EvolvRawAllocations.Key.sessionId.rawValue: "test_sid",
                EvolvRawAllocations.Key.experimentId.rawValue: "test_eid_2",
                EvolvRawAllocations.Key.candidateId.rawValue: "test_cid_2",
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
            let allocations = EvolvAllocations(AllocationsTest.rawAllocations)
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance", participant: participant)
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance", participant: participant)
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetValueFromMultiAllocationGenome() {
        do {
            let participant: EvolvParticipant = EvolvParticipant.builder().build()
            let allocations = EvolvAllocations(AllocationsTest.rawAllocations)
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance", participant: participant)
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance", participant: participant)
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetValueFromMultiAllocationWithDupsGenome() {
        do {
            let participant: EvolvParticipant = EvolvParticipant.builder().build()
            let allocations = EvolvAllocations(self.rawMultiAllocations)
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance", participant: participant)
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance", participant: participant)
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetActiveExperiments() {
        let allocations = EvolvAllocations(self.rawMultiAllocationsWithDups)
        let activeExperiments: Set<String> = allocations.getActiveExperiments()
        var expected: Set<String> = Set()
        expected.update(with: "test_eid")
        expected.update(with: "test_eid_2")
        XCTAssertEqual(expected, activeExperiments)
    }
    
}
