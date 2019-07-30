//
//  EvolvParticipant.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public class EvolvParticipant {
    
    let sessionId: String
    var userId: String
    private(set) var userAttributes: [String: String]
    
    init(userId: String, sessionId: String, userAttributes: [String: String]) {
        self.userId = userId
        self.sessionId = sessionId
        self.userAttributes = userAttributes
    }
    
    public static func builder() -> EvolvParticipantBuilder {
        return EvolvParticipantBuilder()
    }
    
}

public class EvolvParticipantBuilder {
    
    private var userId: String
    private var sessionId: String
    private var userAttributes: [String: String]
    
    init() {
        self.userId = UUID().uuidString
        self.sessionId = UUID().uuidString
        self.userAttributes = [
            EvolvRawAllocations.Key.userId.rawValue: userId,
            EvolvRawAllocations.Key.sessionId.rawValue: sessionId
        ]
    }
    
    /**
     A unique key representing the participant.
     - Parameters:
     - userId: A unique key.
     - Returns: this instance of the participant
     */
    public func set(userId: String) -> EvolvParticipantBuilder {
        self.userId = userId
        return self
    }
    
    /**
     A unique key representing the participant's session.
     - Parameters:
     - sessionId: A unique key.
     - Returns: this instance of the participant
     */
    public func set(sessionId: String) -> EvolvParticipantBuilder {
        self.sessionId = sessionId
        return self
    }
    
    /**
     Sets the users attributes which can be used to filter users upon.
     - Parameters:
     - userAttributes: A map representing specific attributes that describe the participant.
     - Returns: this instance of the participant
     */
    public func set(userAttributes: [String: String]) -> EvolvParticipantBuilder {
        self.userAttributes = userAttributes
        return self
    }
    
    /**
     Builds the EvolvParticipant instance.
     - Returns: an EvolvParticipant instance.
     */
    public func build() -> EvolvParticipant {
        userAttributes.updateValue(userId, forKey: EvolvRawAllocations.Key.userId.rawValue)
        userAttributes.updateValue(sessionId, forKey: EvolvRawAllocations.Key.sessionId.rawValue)
        return EvolvParticipant(userId: userId, sessionId: sessionId, userAttributes: userAttributes)
    }
    
}
