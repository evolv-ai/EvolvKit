//
//  AllocationsTest.swift
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
import PromiseKit
@testable import EvolvKit

class AllocationsTest: XCTestCase {
    
    private var participant: EvolvParticipant!
    private var mockAllocationStore: DefaultEvolvAllocationStore!
    
    override func setUp() {
        super.setUp()
        
        participant = EvolvParticipant.builder().build()
        mockAllocationStore = DefaultEvolvAllocationStore(size: 5)
    }
    
    override func tearDown() {
        super.tearDown()
        
        participant = nil
        mockAllocationStore = nil
    }
    
    func testGetValueFromAllocationGenome() {
        do {
            let allocations = EvolvAllocations(TestData.rawAllocations, store: mockAllocationStore)
            
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
            let allocations = EvolvAllocations(TestData.rawAllocations, store: mockAllocationStore)
            
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
            let allocations = EvolvAllocations(TestData.rawMultiAllocations, store: mockAllocationStore)
            
            let featureImportance = try allocations.value(forKey: "algorithms.feature_importance", participant: participant)
            let weightingDistance = try allocations.value(forKey: "search.weighting.distance", participant: participant)
            
            XCTAssertEqual(featureImportance, false)
            XCTAssertEqual(weightingDistance, 2.5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetActiveExperiments() {
        let allocations = EvolvAllocations(TestData.rawMultiAllocationsWithDups, store: mockAllocationStore)
        
        let activeExperiments: Set<String> = allocations.getActiveExperiments()
        var expected: Set<String> = Set()
        expected.update(with: "test_eid")
        expected.update(with: "test_eid_2")
        
        XCTAssertEqual(expected, activeExperiments)
    }
    
    func test_KeyWithLastDot() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocations, store: mockAllocationStore)
        let key = "search.weighting.distance."
        var result: EvolvRawAllocationNode = EvolvRawAllocationNode.null
        
        // when
        do {
            result = try allocations.value(forKey: key, participant: participant)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertEqual(result, 2.5)
    }
    
    func test_KeyWithEmptyKeyPart() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocations, store: mockAllocationStore)
        let key = "search..weighting.distance"
        var result: EvolvRawAllocationNode = EvolvRawAllocationNode.null
        
        // when
        do {
            result = try allocations.value(forKey: key, participant: participant)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertEqual(result, 2.5)
    }
    
    func test_ThrowValueNotFound() {
        // given
        let allocations = EvolvAllocations([], store: mockAllocationStore)
        let key = "search.weighting.distance"
        
        // when & then
        XCTAssertThrowsError(try allocations.value(forKey: key, participant: participant)) { error in
            XCTAssertEqual(error as! EvolvAllocations.Error, EvolvAllocations.Error.valueNotFound(key: key))
        }
    }
    
    func test_ThrowGenomeEmpty() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocationsWithoutGenome, store: mockAllocationStore)
        let key = "search.weighting.distance"
        
        // when & then
        XCTAssertThrowsError(try allocations.value(forKey: key, participant: participant)) { error in
            XCTAssertEqual(error as! EvolvAllocations.Error, EvolvAllocations.Error.genomeEmpty)
        }
    }
    
    func test_CheckValueType() {
        // given
        let allocations = EvolvAllocations(TestData.rawAllocations, store: mockAllocationStore)
        let key1 = "pages.settings.isMute"
        let key2 = "pages.settings.volume"
        let key3 = "pages.testing_page.megatron"
        let key4 = "pages.all_pages.header_footer"
        let key5 = "pages"
        let key6 = "pages.settings.filter"
        
        // when & then
        // bool
        guard let isMuteNode = try? allocations.value(forKey: key1, participant: participant) else {
            XCTFail("Key \(key1) was not found")
            return
        }
        
        XCTAssertEqual(isMuteNode.type, EvolvRawAllocationNode.NodeType.bool)
        XCTAssertEqual(isMuteNode.boolValue, true)
        
        // number
        guard let volume = try? allocations.value(forKey: key2, participant: participant) else {
            XCTFail("Key \(key2) was not found")
            return
        }
        
        XCTAssertEqual(volume.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(volume.intValue, 1)
        
        // string
        guard let megatron = try? allocations.value(forKey: key3, participant: participant) else {
            XCTFail("Key \(key3) was not found")
            return
        }
        
        XCTAssertEqual(megatron.type, EvolvRawAllocationNode.NodeType.string)
        XCTAssertEqual(megatron.stringValue, "none")
        
        // array
        guard let header_footer = try? allocations.value(forKey: key4, participant: participant) else {
            XCTFail("Key \(key4) was not found")
            return
        }
        
        XCTAssertEqual(header_footer.type, EvolvRawAllocationNode.NodeType.array)
        
        // dict
        guard let pages = try? allocations.value(forKey: key5, participant: participant) else {
            XCTFail("Key \(key5) was not found")
            return
        }
        
        XCTAssertEqual(pages.type, EvolvRawAllocationNode.NodeType.dictionary)
        
        // null
        guard let filter = try? allocations.value(forKey: key6, participant: participant) else {
            XCTFail("Key \(key6) was not found")
            return
        }
        
        XCTAssertEqual(filter.type, EvolvRawAllocationNode.NodeType.null)
    }
    
}
