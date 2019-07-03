//
//  EventEmitter.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class EventEmitter {
  
  private let LOGGER = Log.logger
  
  public let CONFIRM_KEY: String = "confirmation"
  public let CONTAMINATE_KEY: String = "contamination"
  
  let httpClient: HttpProtocol
  let config: EvolvConfig
  let participant: EvolvParticipant
  
  let audience = Audience()
  
  init(config: EvolvConfig, participant: EvolvParticipant) {
    self.config = config
    self.participant = participant
    self.httpClient = config.getHttpClient()
  }
  
  public func emit(_ key: String) -> Void {
    let url: URL = createEventUrl(type: key, score: 1.0)
    _ = makeEventRequest(url)
  }
  
  public func emit(_ key: String, _ score: Double) -> Void {
    let url: URL = createEventUrl(type: key, score: score)
    _ = makeEventRequest(url)
  }
  
  public func confirm(allocations: [JSON]) -> Void {
    sendAllocationEvents(CONFIRM_KEY, allocations)
  }
  
  public func contaminate(allocations: [JSON]) -> Void {
    sendAllocationEvents(CONTAMINATE_KEY, allocations)
  }
  
  public func sendAllocationEvents(_ key: String, _ allocations: [JSON]) {
    if !allocations.isEmpty {
      for a in allocations {
        // TODO: Perform audience check here
        let eid = String(describing: a["eid"])
        let cid = String(describing: a["cid"])
        let url = createEventUrl(type: key, experimentId: eid, candidateId: cid)
        makeEventRequest(url)
        
        // TODO: Add audience filter logic here
        let message: String = "\(key) event filtered"
        LOGGER.log(.debug, message: message)
      }
    }
  }
  
  func createEventUrl(type: String , score: Double ) -> URL {
    var components = URLComponents()
    
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "type", value: "\(type)"),
      URLQueryItem(name: "score", value: "\(String(score))")
    ]
    
    guard let url = components.url else {
      let message: String = "Error creating event url with type and score."
      LOGGER.log(.debug, message: message)
      return URL(string: "")!
    }

    return url
  }
  
  func createEventUrl(type: String, experimentId: String, candidateId: String) -> URL {
    var components = URLComponents()
    
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(experimentId)"),
      URLQueryItem(name: "cid", value: "\(candidateId)"),
      URLQueryItem(name: "type", value: "\(type)")
    ]
    
    guard let url = components.url else {
      let message: String = "Error creating event url with experimentID and candidateID."
      LOGGER.log(.debug, message: message)
      return URL(string: "")!
    }

    return url
  }
  
  private func makeEventRequest(_ url: URL?) -> Void {
    guard let unwrappedUrl = url else {
      let message = "The event url was nil, skipping event request."
      LOGGER.log(.debug, message: message)
      return
    }
    
    let _ = httpClient.sendEvents(url: unwrappedUrl)
  }
}