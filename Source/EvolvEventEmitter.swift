//
//  EvolvEventEmitter.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

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
    
    func confirm(rawAllocations: EvolvRawAllocations) {
        sendAllocationEvents(forKey: Key.confirm.rawValue, rawAllocations: rawAllocations)
    }
    
    func contaminate(rawAllocations: EvolvRawAllocations) {
        sendAllocationEvents(forKey: Key.contaminate.rawValue, rawAllocations: rawAllocations)
    }
    
    func sendAllocationEvents(forKey key: String, rawAllocations: EvolvRawAllocations) {
        if !rawAllocations.isEmpty {
            for allocation in rawAllocations {
                // TODO: Perform audience check here
                let experimentId = String(describing: allocation[EvolvRawAllocations.Key.experimentId.rawValue])
                let candidateId = String(describing: allocation[EvolvRawAllocations.Key.candidateId.rawValue])
                let url = createEventUrl(type: key, experimentId: experimentId, candidateId: candidateId)
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
            URLQueryItem(name: EvolvRawAllocations.Key.userId.rawValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.sessionId.rawValue, value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.type.rawValue, value: "\(type)"),
            URLQueryItem(name: EvolvRawAllocations.Key.score.rawValue, value: "\(String(score))")
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
            URLQueryItem(name: EvolvRawAllocations.Key.userId.rawValue, value: "\(participant.userId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.sessionId.rawValue, value: "\(participant.sessionId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.experimentId.rawValue, value: "\(experimentId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.candidateId.rawValue, value: "\(candidateId)"),
            URLQueryItem(name: EvolvRawAllocations.Key.type.rawValue, value: "\(type)")
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
