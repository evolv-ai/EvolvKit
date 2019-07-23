import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class EvolvParticipantTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  func testBuildDefaultParticipant() {
    let participant = EvolvParticipant.builder().build()
    XCTAssertNotNil(participant.getUserId)
    XCTAssertNotNil(participant.getSessionId)
    XCTAssertNotNil(participant.getUserAttributes)
  }
  
  func testSetCustomParticipantAttributes() {
    let userId = "Testy"
    let sessionId = "McTestTest"
    let userAttributes = ["country" : "us"]
    
    let participant = EvolvParticipant.builder()
      .setUserId(userId: userId)
      .setSessionId(sessionId: sessionId)
      .setUserAttributes(userAttributes: userAttributes)
      .build()
    
    XCTAssertEqual(userId, participant.getUserId())
    XCTAssertEqual(sessionId, participant.getSessionId())
    
    var expectedUserAttributes = [String : String]()
    expectedUserAttributes["country"] = String("us")
    expectedUserAttributes["uid"] = String(userId)
    expectedUserAttributes["sid"] = String(sessionId)
    
    XCTAssertEqual(expectedUserAttributes, participant.getUserAttributes())
  }
  
  func testSetUserIdAfterParticipantCreated() {
    let newUserId = "Testy"
    let participant = EvolvParticipant.builder().build()
    let oldUserId = participant.getUserId()
    participant.setUserId(userId: newUserId)
    
    XCTAssertNotEqual(oldUserId, newUserId)
    XCTAssertEqual(newUserId, participant.getUserId())
  }
  
  func testParticipantGetUserAttr(){
    let p = EvolvParticipant.builder().setUserId(userId: "test_user").setSessionId(sessionId: "test_session").build()
    let userAttributes = p.getUserAttributes()
    let expectedUserAttributes = ["uid":"test_user", "sid":"test_session"]
    XCTAssertEqual(userAttributes["uid"], expectedUserAttributes["uid"])
    XCTAssertEqual(userAttributes["sid"], expectedUserAttributes["sid"])
  }
  
  func testEvolvParticipant() {
    let p = EvolvParticipant.builder().build()
    p.setUserId(userId: "test_user")
    XCTAssertEqual(p.getUserId(), "test_user")
  }
}
