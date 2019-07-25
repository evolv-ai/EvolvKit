//
//  CustomAllocationStore.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
import EvolvKit
import SwiftyJSON

public class CustomAllocationStore: AllocationStoreProtocol {
  /*
   A custom in memory allocation store, this is a very basic example. One would likely use
   sqlLite or an application storage implementation instead. SwiftyJSON is a required package for
   implementing the store. You can install SwiftyJSON here: https://cocoapods.org/pods/SwiftyJSON.
  */
  
  typealias JsonArray = [JSON]
  
  private var allocations: [String: [JSON]]
  
  init() {
    self.allocations = Dictionary()
  }
  
  public func get(_ participantId: String) -> [JSON] {
    return allocations[participantId] ?? [JSON]()
  }
  
  public func put(_ participantId: String, _ allocations: [JSON]) {
    self.allocations.updateValue(allocations, forKey: participantId)
  }
  
}
