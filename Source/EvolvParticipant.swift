//
//  EvolvParticipant.swift
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

/// The end user of the application, the individual who's actions are being recorded in the experiment.
public class EvolvParticipant: NSObject {
    
    let sessionId: String
    var userId: String
    private(set) var userAttributes: [String: String]
    
    init(userId: String, sessionId: String, userAttributes: [String: String]) {
        self.userId = userId
        self.sessionId = sessionId
        self.userAttributes = userAttributes
    }
    
    @objc public static func builder() -> EvolvParticipantBuilder {
        return EvolvParticipantBuilder()
    }
    
}

public class EvolvParticipantBuilder: NSObject {
    
    private var userId: String
    private var sessionId: String
    private var userAttributes: [String: String]
    
    override init() {
        self.userId = UUID().uuidString
        self.sessionId = UUID().uuidString
        self.userAttributes = [
            EvolvRawAllocation.CodingKey.userId.stringValue: userId,
            EvolvRawAllocation.CodingKey.sessionId.stringValue: sessionId
        ]
        super.init()
    }
    
    /// A unique key representing the participant.
    ///
    /// - Parameter userId: A unique key.
    /// - Returns: this instance of the participant
    @objc public func set(userId: String) -> EvolvParticipantBuilder {
        self.userId = userId
        return self
    }
    
    /// A unique key representing the participant's session.
    ///
    /// - Parameter sessionId: A unique key.
    /// - Returns: this instance of the participant
    @objc public func set(sessionId: String) -> EvolvParticipantBuilder {
        self.sessionId = sessionId
        return self
    }
    
    /// Sets the users attributes which can be used to filter users upon.
    ///
    /// - Parameter userAttributes: A map representing specific attributes that describe the participant.
    /// - Returns: this instance of the participant
    @objc public func set(userAttributes: [String: String]) -> EvolvParticipantBuilder {
        self.userAttributes = userAttributes
        return self
    }
    
    /// Builds the EvolvParticipant instance.
    ///
    /// - Returns: an EvolvParticipant instance.
    @objc public func build() -> EvolvParticipant {
        userAttributes.updateValue(userId, forKey: EvolvRawAllocation.CodingKey.userId.stringValue)
        userAttributes.updateValue(sessionId, forKey: EvolvRawAllocation.CodingKey.sessionId.stringValue)
        return EvolvParticipant(userId: userId, sessionId: sessionId, userAttributes: userAttributes)
    }
    
}
