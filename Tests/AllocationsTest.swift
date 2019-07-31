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
    
    func testGetValueFromAllocationGenome() {
        do {
            let participant = EvolvParticipant.builder().build()
            let allocations = EvolvAllocations(TestData.rawAllocations)
            
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
            let allocations = EvolvAllocations(TestData.rawAllocations)
            
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
            let allocations = EvolvAllocations(TestData.rawMultiAllocations)
            
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance", participant: participant)
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance", participant: participant)
            
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetActiveExperiments() {
        let allocations = EvolvAllocations(TestData.rawMultiAllocationsWithDups)
        
        let activeExperiments: Set<String> = allocations.getActiveExperiments()
        var expected: Set<String> = Set()
        expected.update(with: "test_eid")
        expected.update(with: "test_eid_2")
        
        XCTAssertEqual(expected, activeExperiments)
    }
    
}
