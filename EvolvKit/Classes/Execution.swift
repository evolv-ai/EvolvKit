//
//  Execution.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON


class Execution<T> {
  
  private let key: String
  private let participant: EvolvParticipant
  private var defaultValue: T
  private var alreadyExecuted: Set<String> = Set()
  private var closure : (T) -> ()
  
  init(_ key: String,
       _ defaultValue: T,
       _ participant: EvolvParticipant,
       _ closure: @escaping (T) -> ()) {
    self.key = key
    self.defaultValue = defaultValue
    self.participant = participant
    self.closure = closure
  }
  
  func getKey() -> String { return key }
  
  func getMyType(_ element: Any) -> Any.Type {
    return type(of: element)
  }
  
  func executeWithAllocation(rawAllocations: [JSON]) throws -> Void {
    let type = getMyType(defaultValue)
    let allocations = Allocations(allocations: rawAllocations)
    let optionalValue = try allocations.getValueFromAllocations(key, type, participant)
  
    guard let value = optionalValue else {
      throw EvolvKeyError.errorMessage
    }
    
    guard let genericValue = value.rawValue as? T else {
      throw EvolvKeyError.mismatchTypes
    }
    
    let activeExperiements = allocations.getActiveExperiments()
    if alreadyExecuted.isEmpty || alreadyExecuted == activeExperiements {
      // there was a change to the allocations after reconciliation, apply changes
      closure(genericValue)
    }
    alreadyExecuted = activeExperiements
  }
  
  func executeWithDefault() -> Void {
    closure(defaultValue)
  }
}
