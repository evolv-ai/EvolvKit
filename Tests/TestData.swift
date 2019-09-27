//
//  TestData.swift
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

import Foundation
@testable import EvolvKit

class TestData {
    
    private static var jsonDecoder: JSONDecoder = JSONDecoder()
    private static let logger = EvolvLogger.shared
    
    static var rawAllocations: [EvolvRawAllocation] {
        return decode(fromFile: "rawAllocationsString")
    }
    
    static var rawMultiAllocations: [EvolvRawAllocation] {
        return decode(fromFile: "rawMultiAllocationsString")
    }
    
    static var rawMultiAllocations2: [EvolvRawAllocation] {
        return decode(fromFile: "rawMultiAllocations2String")
    }
    
    static var rawMultiAllocationsWithDups: [EvolvRawAllocation] {
        return decode(fromFile: "rawMultiAllocationsWithDupsString")
    }
    
    static var rawAllocationsWithAudience: [EvolvRawAllocation] {
        return decode(fromFile: "rawAllocationsWithAudienceString")
    }
    
    static var rawAllocationsWithoutGenome: [EvolvRawAllocation] {
        return [EvolvRawAllocation(experimentId: "test_eid",
                                   userId: "test_uid",
                                   candidateId: "test_cid",
                                   genome: EvolvRawAllocationNode.null,
                                   excluded: false,
                                   sessionId: "test_sid")]
    }
    
}

extension TestData {
    
    static func rawJSONString(fromFile fileName: String) -> String {
        if let path = Bundle(for: TestData.self).path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return String(data: data, encoding: .utf8) ?? ""
            } catch let error {
                logger.error(error)
            }
        }
        
        return ""
    }
    
    private static func decode(fromFile fileName: String) -> [EvolvRawAllocation] {
        var rawAllocations: [EvolvRawAllocation] = []
        
        if let path = Bundle(for: TestData.self).path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                rawAllocations = try jsonDecoder.decode([EvolvRawAllocation].self, from: data)
            } catch let error {
                logger.error(error)
            }
        }
        
        return rawAllocations
    }
    
}
