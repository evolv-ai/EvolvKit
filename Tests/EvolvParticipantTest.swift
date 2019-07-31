import XCTest
import SwiftyJSON
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
        expectedUserAttributes[EvolvRawAllocations.Key.userId.rawValue] = String(userId)
        expectedUserAttributes[EvolvRawAllocations.Key.sessionId.rawValue] = String(sessionId)
        
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
        let expectedUserAttributes = [EvolvRawAllocations.Key.userId.rawValue: "test_user",
                                      EvolvRawAllocations.Key.sessionId.rawValue: "test_session"]
        XCTAssertEqual(userAttributes[EvolvRawAllocations.Key.userId.rawValue],
                       expectedUserAttributes[EvolvRawAllocations.Key.userId.rawValue])
        XCTAssertEqual(userAttributes[EvolvRawAllocations.Key.sessionId.rawValue],
                       expectedUserAttributes[EvolvRawAllocations.Key.sessionId.rawValue])
    }
    
    func testEvolvParticipant() {
        let participant = EvolvParticipant.builder().build()
        participant.userId = "test_user"
        XCTAssertEqual(participant.userId, "test_user")
    }
    
}
