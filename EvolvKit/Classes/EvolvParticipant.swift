//
//  EvolvParticipant.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class EvolvParticipant {
  private let sessionId: String
  private var userId: String
  private var userAttributes: [String: String]
  
  init(_ userId: String, _ sessionId: String, _ userAttributes: [String: String]) {
    self.userId = userId
    self.sessionId = sessionId
    self.userAttributes = userAttributes
  }
  
  public static func builder() -> ParticipantBuilder {
    return ParticipantBuilder()
  }
  
  public func getUserId() -> String { return userId }
  
  public func getSessionId() -> String { return sessionId }
  
  public func getUserAttributes() -> [String: String] { return userAttributes }
  
  public func setUserId(_ userId: String) {
    self.userId = userId
  }
}

public class ParticipantBuilder {
  private var userId: String
  private var sessionId: String
  private var userAttributes: [String: String]
  
  init() {
    self.userId = UUID().uuidString
    self.sessionId = UUID().uuidString
    self.userAttributes = ["uid": userId, "sid": sessionId]
  }
  
  /**
   A unique key representing the participant.
   - Parameters:
      - userId: A unique key.
   - Returns: this instance of the participant
   */
  public func setUserId(_ userId: String) -> ParticipantBuilder {
    self.userId = userId
    return self
  }
  
  /**
   A unique key representing the participant's session.
   - Parameters:
      - sessionId: A unique key.
   - Returns: this instance of the participant
   */
  public func setSessionId(_ sessionId: String) -> ParticipantBuilder {
    self.sessionId = sessionId
    return self
  }
  
  /**
   Sets the users attributes which can be used to filter users upon.
   - Parameters:
      - userAttributes: A map representing specific attributes that describe the participant.
   - Returns: this instance of the participant
   */
  public func setUserAttributes(_ userAttributes: [String: String]) -> ParticipantBuilder {
    self.userAttributes = userAttributes
    return self
  }
  
  /**
   Builds the EvolvParticipant instance.
   - Returns: an EvolvParticipant instance.
   */
  public func build() -> EvolvParticipant {
    self.userAttributes.updateValue(self.userId, forKey: "uid")
    self.userAttributes.updateValue(self.sessionId, forKey: "sid")
    return EvolvParticipant(self.userId, self.sessionId, self.userAttributes)
  }
}
