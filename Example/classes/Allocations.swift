//
//  Allocations.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Allocations {
  let allocations: [JSON]
  let audience : Audience = Audience()
  
  init (allocations: [JSON]) {
    self.allocations = allocations
  }
  
  func getMyType<T>(_ element: T) -> Any? {
    return type(of: element)
  }
  
  func getValueFromAllocations<T>(_ key: String, _ type: T, _ participant: EvolvParticipant) throws -> JSON? {
    var keyParts = [String]()
    keyParts = key.components(separatedBy: "\\.")
    if (keyParts.isEmpty) { throw EvolvKeyError(rawValue: "Key provided was empty.")! }
    let alloc = self.allocations
    for a in alloc {
      let genome = a["genome"]
      let element = try getElementFromGenome(genome: genome, keyParts: keyParts)
      if !(element.error != nil) {
        return element
      } else {
        throw EvolvKeyError.errorMessage
      }
    }
    let errorJson = JSON([key: "Unable to find key in experiment"])
    return errorJson
  }
  
  private func getElementFromGenome(genome: JSON, keyParts: [String]) throws -> JSON {
    var element: JSON = genome
    if element == nil {
      throw EvolvKeyError(rawValue: "Allocation genome was empty")!
    }
    
    for part: String in keyParts {
      do {
        let object = genome[part]
        element = object
        if (element.error == nil) {
          break
        }
      } catch {
        throw EvolvKeyError(rawValue: "element fails")!
      }
    }
    return element
  }
  
  static public func reconcileAllocations(previousAllocations: [JSON], currentAllocations: [JSON]) -> [JSON] {
    var allocations = [JSON]()
    
    for ca in currentAllocations {
      let currentEid = String(describing: ca["eid"])
      var previousFound = false
      
      for pa in previousAllocations {
        var previousEid = String(describing: pa["eid"])
        
        if currentEid.elementsEqual(previousEid) {
          allocations.append(pa)
          previousFound = true
        }
      }
      if !previousFound { allocations.append(ca) }
    }
    return allocations
  }
  
  
  public func getActiveExperiments() -> Set<String> {
    var activeExperiments = Set<String>()
    for a in allocations {
      let eid = String(describing: a["eid"])
      activeExperiments.insert(eid)
    }
    return activeExperiments
  }
}
