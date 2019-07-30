//
//  DefaultEvolvAllocationStore.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class DefaultEvolvAllocationStore: EvolvAllocationStore {
    
    public var cache: LRUCache
    
    public init(size: Int) {
        cache = LRUCache(size)
    }
    
    public func get(_ participantId: String) -> EvolvRawAllocations {
        return cache.getEntry(participantId)
    }
    
    public func put(_ participantId: String, _ rawAllocations: EvolvRawAllocations) {
        cache.putEntry(participantId, rawAllocations)
    }
    
}
