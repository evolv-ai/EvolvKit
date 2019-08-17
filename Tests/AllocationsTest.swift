//
//  AllocationsTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import PromiseKit
@testable import EvolvKit

class AllocationsTest: XCTestCase {
    
    func testGetValueFromAllocationGenome() {
        do {
            let allocations = EvolvAllocations(TestData.rawAllocations)
            
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance")
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance")
            
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetValueFromMultiAllocationGenome() {
        do {
            let allocations = EvolvAllocations(TestData.rawAllocations)
            
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance")
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance")
            
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetValueFromMultiAllocationWithDupsGenome() {
        do {
            let allocations = EvolvAllocations(TestData.rawMultiAllocations)
            
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance")
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance")
            
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
    
    func test_KeyWithLastDot() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocations)
        let key = "search.weighting.distance."
        var result: EvolvRawAllocationNode = EvolvRawAllocationNode.null
        
        // when
        do {
            result = try allocations.value(forKey: key)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertEqual(result, 2.5)
    }
    
    func test_KeyWithEmptyKeyPart() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocations)
        let key = "search..weighting.distance"
        var result: EvolvRawAllocationNode = EvolvRawAllocationNode.null
        
        // when
        do {
            result = try allocations.value(forKey: key)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertEqual(result, 2.5)
    }
    
    func test_ThrowValueNotFound() {
        // given
        let allocations = EvolvAllocations([])
        let key = "search.weighting.distance"
        
        // when & then
        XCTAssertThrowsError(try allocations.value(forKey: key)) { error in
            XCTAssertEqual(error as! EvolvAllocations.Error, EvolvAllocations.Error.valueNotFound(key: key))
        }
    }
    
    func test_ThrowGenomeEmpty() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocationsWithoutGenome)
        let key = "search.weighting.distance"
        
        // when & then
        XCTAssertThrowsError(try allocations.value(forKey: key)) { error in
            XCTAssertEqual(error as! EvolvAllocations.Error, EvolvAllocations.Error.genomeEmpty)
        }
    }
    
    func test_ThrowIncorrectKeyPart() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocations)
        let key = "search.weighting2.distance"
        
        // when & then
        XCTAssertThrowsError(try allocations.value(forKey: key)) { error in
            XCTAssertEqual(error as! EvolvRawAllocationNode.Error,
                           EvolvRawAllocationNode.Error.incorrectKey(key: "search.weighting2"))
        }
    }
    
}
