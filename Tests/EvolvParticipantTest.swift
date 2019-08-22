//
//  EvolvParticipantTest.swift
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

class EvolvParticipantTest: XCTestCase {
    
    func testBuildDefaultParticipant() {
        let participant = EvolvParticipant.builder().build()
        
        XCTAssertNotNil(participant.userId)
        XCTAssertNotNil(participant.sessionId)
        XCTAssertNotNil(participant.userAttributes)
    }
    
    func testSetCustomParticipantAttributes() {
        let userId = "Testy"
        let sessionId = "McTestTest"
        let userAttributes = ["country": "us"]
        
        let participant = EvolvParticipant.builder()
            .set(userId: userId)
            .set(sessionId: sessionId)
            .set(userAttributes: userAttributes)
            .build()
        
        XCTAssertEqual(userId, participant.userId)
        XCTAssertEqual(sessionId, participant.sessionId)
        
        var expectedUserAttributes: [String: String] = [:]
        expectedUserAttributes["country"] = String("us")
        expectedUserAttributes[EvolvRawAllocation.CodingKey.userId.stringValue] = String(userId)
        expectedUserAttributes[EvolvRawAllocation.CodingKey.sessionId.stringValue] = String(sessionId)
        
        XCTAssertEqual(expectedUserAttributes, participant.userAttributes)
    }
    
    func testSetUserIdAfterParticipantCreated() {
        let newUserId = "Testy"
        let participant = EvolvParticipant.builder().build()
        let oldUserId = participant.userId
        participant.userId = newUserId
        
        XCTAssertNotEqual(oldUserId, newUserId)
        XCTAssertEqual(newUserId, participant.userId)
    }
    
    func testParticipantGetUserAttr() {
        let participant = EvolvParticipant.builder()
            .set(userId: "test_user")
            .set(sessionId: "test_session")
            .build()
        let userAttributes = participant.userAttributes
        let expectedUserAttributes = [EvolvRawAllocation.CodingKey.userId.stringValue: "test_user",
                                      EvolvRawAllocation.CodingKey.sessionId.stringValue: "test_session"]
        XCTAssertEqual(userAttributes[EvolvRawAllocation.CodingKey.userId.stringValue],
                       expectedUserAttributes[EvolvRawAllocation.CodingKey.userId.stringValue])
        XCTAssertEqual(userAttributes[EvolvRawAllocation.CodingKey.sessionId.stringValue],
                       expectedUserAttributes[EvolvRawAllocation.CodingKey.sessionId.stringValue])
    }
    
    func testEvolvParticipant() {
        let participant = EvolvParticipant.builder().build()
        participant.userId = "test_user"
        XCTAssertEqual(participant.userId, "test_user")
    }
    
}
