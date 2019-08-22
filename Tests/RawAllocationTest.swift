//
//  RawAllocationTest.swift
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

class RawAllocationTest: XCTestCase {
    
    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        jsonDecoder = JSONDecoder()
    }
    
    override func tearDown() {
        super.tearDown()
        
        jsonDecoder = nil
    }
    
    func test_Init() {
        // given
        let experimentId = "test_experimentId"
        let userId = "test_userId"
        let sessionId = "test_sessionId"
        let candidateId = "test_candidateId"
        let genome = EvolvRawAllocationNode.null
        
        let rawAllocation1 = EvolvRawAllocation(experimentId: experimentId,
                                                userId: userId,
                                                candidateId: candidateId,
                                                genome: genome,
                                                excluded: true,
                                                sessionId: sessionId)
        let rawAllocation2 = EvolvRawAllocation(experimentId: experimentId,
                                                userId: userId,
                                                candidateId: candidateId,
                                                genome: genome,
                                                excluded: false)
        
        // when & then
        XCTAssertNotNil(rawAllocation1)
        XCTAssertEqual(rawAllocation1.experimentId, experimentId)
        XCTAssertEqual(rawAllocation1.userId, userId)
        XCTAssertEqual(rawAllocation1.sessionId, sessionId)
        XCTAssertEqual(rawAllocation1.candidateId, candidateId)
        XCTAssertEqual(rawAllocation1.genome, genome)
        XCTAssertEqual(rawAllocation1.excluded, true)
        XCTAssertNotNil(rawAllocation2)
        XCTAssertEqual(rawAllocation2.sessionId, nil)
        XCTAssertEqual(rawAllocation2.excluded, false)
    }
    
    func test_Decode() {
        // given
        let jsonString = """
        [
            {
                "uid":"test_uid",
                "sid":"test_sid",
                "eid":"test_eid_2",
                "cid":"test_cid_2",
                "genome":{
                    "best":{
                        "baked":{
                        "cookie":true,
                        "cake":false
                        }
                    },
                    "utensils":{
                        "knives":{
                            "drawer":[
                                "butcher",
                                "paring"
                            ]
                        },
                        "spoons":{
                            "wooden":"oak",
                            "metal":"steel"
                        }
                    },
                    "algorithms":{
                        "feature_importance":true
                    }
                },
                "excluded":false
            }
        ]
        """
   
        var rawAllocations: [EvolvRawAllocation] = []
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            rawAllocations = try jsonDecoder.decode([EvolvRawAllocation].self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(rawAllocations)
        XCTAssertNotNil(rawAllocations[0])
        XCTAssertEqual(rawAllocations[0].candidateId, "test_cid_2")
        XCTAssertEqual(rawAllocations[0].sessionId, "test_sid")
        XCTAssertEqual(rawAllocations[0].experimentId, "test_eid_2")
        XCTAssertEqual(rawAllocations[0].userId, "test_uid")
        XCTAssertEqual(rawAllocations[0].excluded, false)
        XCTAssertNotNil(rawAllocations[0].genome)
        XCTAssertEqual(rawAllocations[0].genome.type, .dictionary)
    }
    
    func test_DecodeWithoutSessionId() {
        // given
        let jsonString = """
        [
            {
                "uid":"test_uid",
                "eid":"test_eid_2",
                "cid":"test_cid_2",
                "genome":{
                    "best":{
                        "baked":{
                        "cookie":true,
                        "cake":false
                        }
                    }
                },
                "excluded":false
            }
        ]
        """
        
        var rawAllocations: [EvolvRawAllocation] = []
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            rawAllocations = try jsonDecoder.decode([EvolvRawAllocation].self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(rawAllocations)
        XCTAssertNotNil(rawAllocations[0])
        XCTAssertEqual(rawAllocations[0].candidateId, "test_cid_2")
        XCTAssertEqual(rawAllocations[0].sessionId, nil)
        XCTAssertEqual(rawAllocations[0].experimentId, "test_eid_2")
        XCTAssertEqual(rawAllocations[0].userId, "test_uid")
        XCTAssertEqual(rawAllocations[0].excluded, false)
        XCTAssertNotNil(rawAllocations[0].genome)
        XCTAssertEqual(rawAllocations[0].genome.type, .dictionary)
    }
    
    func test_Equatable() {
        // given
        let jsonString = """
        [
            {
                "uid":"test_uid",
                "eid":"test_eid_2",
                "cid":"test_cid_2",
                "genome":{
                    "best":{
                        "baked":{
                        "cookie":true,
                        "cake":false
                        }
                    }
                },
                "excluded":false
            }
        ]
        """
        
        var rawAllocations1: [EvolvRawAllocation] = []
        var rawAllocations2: [EvolvRawAllocation] = []
        let rawAllocation = EvolvRawAllocation(experimentId: "test_eid_2",
                                               userId: "test_uid",
                                               candidateId: "test_cid_2",
                                               genome: EvolvRawAllocationNode.null,
                                               excluded: false)
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            rawAllocations1 = try jsonDecoder.decode([EvolvRawAllocation].self, from: data)
            rawAllocations2 = try jsonDecoder.decode([EvolvRawAllocation].self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(rawAllocations1)
        XCTAssertNotNil(rawAllocations1[0])
        XCTAssertNotNil(rawAllocations2)
        XCTAssertNotNil(rawAllocations2[0])
        XCTAssertEqual(rawAllocations1[0], rawAllocations2[0])
        XCTAssertNotEqual(rawAllocations1[0], rawAllocation)
    }
    
}
