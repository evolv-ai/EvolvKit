//
//  EvolvEventEmitter.swift
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

class EvolvEventEmitter {
    
    enum Key: String {
        case confirm = "confirmation"
        case contaminate = "contamination"
    }
    
    private let logger = EvolvLogger.shared
    
    private let httpClient: EvolvHttpClient
    private let config: EvolvConfig
    private let participant: EvolvParticipant
    
    init(config: EvolvConfig, participant: EvolvParticipant) {
        self.config = config
        self.participant = participant
        self.httpClient = config.httpClient
    }
    
    func emit(forKey key: String) {
        guard let url = createEventUrl(type: key, score: 1.0) else {
            return
        }
        
        makeEventRequest(url)
    }
    
    func emit(forKey key: String, score: Double) {
        guard let url: URL = createEventUrl(type: key, score: score) else {
            return
        }
        
        makeEventRequest(url)
    }
    
    func confirm(rawAllocations: [EvolvRawAllocation]) {
        sendAllocationEvents(forKey: Key.confirm.rawValue, rawAllocations: rawAllocations)
    }
    
    func contaminate(rawAllocations: [EvolvRawAllocation]) {
        sendAllocationEvents(forKey: Key.contaminate.rawValue, rawAllocations: rawAllocations)
    }
    
    func sendAllocationEvents(forKey key: String, rawAllocations: [EvolvRawAllocation]) {
        if !rawAllocations.isEmpty {
            for allocation in rawAllocations {
                // TODO: Perform audience check here
                let url = createEventUrl(type: key,
                                         experimentId: allocation.experimentId,
                                         candidateId: allocation.candidateId)
                makeEventRequest(url)
                
                // TODO: Add audience filter logic here
                logger.debug("\(key) event filtered")
            }
        }
    }
    
    func createEventUrl(type: String, score: Double) -> URL? {
        var components = URLComponents()
        components.scheme = config.httpScheme
        components.host = config.domain
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue, value: "\(participant.sessionId)"),
            URLQueryItem(name: "type", value: "\(type)"),
            URLQueryItem(name: "score", value: "\(String(score))")
        ]
        
        guard let url = components.url else {
            logger.debug("Error creating event url with type and score.")
            return nil
        }
        
        return url
    }
    
    func createEventUrl(type: String, experimentId: String, candidateId: String) -> URL? {
        var components = URLComponents()
        components.scheme = config.httpScheme
        components.host = config.domain
        components.path = "/\(config.version)/\(config.environmentId)/events"
        components.queryItems = [
            URLQueryItem(name: EvolvRawAllocation.CodingKey.userId.stringValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.sessionId.stringValue, value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.experimentId.stringValue, value: "\(experimentId)"),
            URLQueryItem(name: EvolvRawAllocation.CodingKey.candidateId.stringValue, value: "\(candidateId)"),
            URLQueryItem(name: "type", value: "\(type)")
        ]
        
        guard let url = components.url else {
            logger.debug("Error creating event url with experimentID and candidateID.")
            return nil
        }
        
        return url
    }
    
    private func makeEventRequest(_ url: URL?) {
        guard let unwrappedUrl = url else {
            logger.debug("The event url was nil, skipping event request.")
            return
        }
        
        httpClient.sendEvents(unwrappedUrl)
    }
    
}
