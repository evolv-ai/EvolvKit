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
  
  private var allocations: Dictionary<String, [JSON]>
  
  init() {
    self.allocations = Dictionary()
  }
  
  public func get(uid: String) -> [JSON] {
    return allocations[uid] ?? [JSON]()
  }
  
  public func put(uid: String, allocations: [JSON]) {
    self.allocations.updateValue(allocations, forKey: uid)
  }
  
}
