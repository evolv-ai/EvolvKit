//
//  EvolvRawAllocation.swift
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

/// The set of configurations that have been given to the participant, the values that are being
/// experimented against
public class EvolvRawAllocation: NSObject, Decodable {
    
    struct State: OptionSet {
        let rawValue: Int
        
        static let touched = State(rawValue: 1 << 0)
        static let confirmed = State(rawValue: 1 << 1)
        static let contaminated = State(rawValue: 1 << 2)
        
        static let submitted: State = [.confirmed, .contaminated]
    }
    
    /// The unique identifier of the experiment.
    public let experimentId: String
    /// The unique identifier of the Participant.
    public let userId: String
    /// The unique identifier of the Participant's current session.
    public let sessionId: String?
    /// The unique identifier of variation
    public let candidateId: String
    /// The specific treatments to be applied to the end users experience
    public let genome: EvolvRawAllocationNode
    /// User has been excluded from the experiment
    public let excluded: Bool
    /// Query the specific audience filter defined by project
    public let audienceQuery: EvolvQuery?
    /// Local state
    var state: State = []
    
    enum CodingKey: String, Swift.CodingKey {
        case experimentId = "eid"
        case userId = "uid"
        case sessionId = "sid"
        case candidateId = "cid"
        case genome
        case excluded
        case audienceQuery = "audience_query"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        experimentId = try container.decode(String.self, forKey: .experimentId)
        userId = try container.decode(String.self, forKey: .userId)
        sessionId = try container.decodeIfPresent(String.self, forKey: .sessionId)
        candidateId = try container.decode(String.self, forKey: .candidateId)
        genome = try container.decode(EvolvRawAllocationNode.self, forKey: .genome)
        excluded = try container.decode(Bool.self, forKey: .excluded)
        
        if let audienceQuery = try? container.decodeIfPresent(EvolvQuery.self, forKey: .audienceQuery) {
            self.audienceQuery = audienceQuery
        } else {
            self.audienceQuery = nil
        }
    }
    
    public init(experimentId: String,
                userId: String,
                candidateId: String,
                genome: EvolvRawAllocationNode,
                excluded: Bool,
                sessionId: String? = nil,
                audienceQuery: EvolvQuery? = nil) {
        self.experimentId = experimentId
        self.userId = userId
        self.sessionId = sessionId
        self.candidateId = candidateId
        self.genome = genome
        self.excluded = excluded
        self.audienceQuery = audienceQuery
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? EvolvRawAllocation else {
            return false
        }
        
        return object.experimentId == experimentId &&
            object.userId == userId &&
            object.candidateId == candidateId &&
            object.genome == genome &&
            object.excluded == excluded &&
            object.sessionId == sessionId
    }
    
    /// Determines whether on not to filter the user based upon the supplied user
    /// attributes and allocation.
    ///
    /// - Parameter userAttributes: map representing attributes that represent the participant
    /// - Returns: if participant should be filters, false if not
    public func isFilter(userAttributes: [String: String]) -> Bool {
        guard excluded == false else {
            return true
        }
        
        guard let query = audienceQuery else {
            return false
        }
        
        return !EvolvQuery.evaluate(query, userAttributes: userAttributes)
    }
    
}
