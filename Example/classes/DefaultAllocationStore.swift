//
//  DefaultAllocationStore.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

public class DefaultAllocationStore : AllocationStoreProtocol {
  private var cache: LRUCache
  
  init(size: Int) {
    self.cache = LRUCache(size)
  }
  public func get(uid: String) -> [JSON]? {
    return cache.get(uid)
  }
  
  public func set(uid: String, allocations: [JSON]) {
    cache.set(uid, val: allocations)
  }
}
