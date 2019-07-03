//
//  EventEmitter.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

public class EventEmitter {
  
  private let LOGGER = Log.logger
  
  public static let CONFIRM_KEY: String = "confirmation"
  public static let CONTAMINATE_KEY: String = "contamination"
  
  let httpClient: HttpProtocol
  let config: EvolvConfig
  let participant: EvolvParticipant
  
  let audience = Audience()
  
  init(config: EvolvConfig,
       participant: EvolvParticipant,
       httpClient: HttpProtocol = EvolvHttpClient()) {
    self.config = config
    self.participant = participant
    self.httpClient = httpClient
  }
  
  public func emit(_ key: String) -> Void {
    let url: URL = createEventUrl(key, 1.0)
    makeEventRequest(url)
  }
  
  public func emit(_ key: String, _ score: Double) -> Void {
    let url: URL = createEventUrl(key, score);
    makeEventRequest(url);
  }
  
  public func confirm(allocations: [JSON]) -> Void {
    sendAllocationEvents(EventEmitter.CONFIRM_KEY, allocations);
  }
  
  public func contaminate(allocations: [JSON]) -> Void {
    sendAllocationEvents(EventEmitter.CONTAMINATE_KEY, allocations);
  }
  
  public func sendAllocationEvents(_ key: String, _ allocations: [JSON]) {
    if !allocations.isEmpty {
      for a in allocations {
        // TODO: Perform audience check here
        let eid = String(describing: a["eid"])
        let cid = String(describing: a["cid"])
        let url = createEventUrl(type: key, experimentId: eid, candidateId: cid)
        makeEventRequest(url)
        
        // if the event is filtered: send message
        let message: String = "\(key) event filtered"
        LOGGER.log(.debug, message: message)
      }
    }
  }
  
  func createEventUrl(_ type: String , _ score: Double ) -> URL {
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
      let message: String = "Error creating event url with Experiment ID and Candidate ID."
      LOGGER.log(.debug, message: message)
      return URL(string: "")!
    }
    return url
  }
  
  private func makeEventRequest(_ url: URL?) -> Void {
    // TODO: finish this method, ensure is async
    guard let url = url else {
      let message = "The event url was nil, skipping event request."
      LOGGER.log(.debug, message: message)
      return
    }
    let _ = httpClient.post(url: url).done { (rsp) in
      print(rsp)
    }
  }
}
