//
//  LruCache.swift
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

public class LRUCache {
    
    private let maxSize: Int
    private var cache: [String: [EvolvRawAllocation]] = [:]
    private var priority: LinkedList<String> = LinkedList<String>()
    private var key2node: [String: LinkedList<String>.LinkedListNode<String>] = [:]
    
    public init(_ maxSize: Int) {
        self.maxSize = maxSize
    }
    
    public func getEntry(_ key: String) -> [EvolvRawAllocation] {
        guard let val = cache[key] else {
            return []
        }
        
        remove(key)
        insert(key, val)
        
        return val
    }
    
    public func putEntry(_ key: String, _ value: [EvolvRawAllocation]) {
        if cache[key] != nil {
            remove(key)
        } else if priority.count >= maxSize, let keyToRemove = priority.last?.value {
            remove(keyToRemove)
        }
        
        insert(key, value)
    }
    
    private func remove(_ key: String) {
        cache.removeValue(forKey: key)
        
        guard let node = key2node[key] else {
            return
        }
        
        priority.remove(node: node)
        key2node.removeValue(forKey: key)
    }
    
    private func insert(_ key: String, _ value: [EvolvRawAllocation]) {
        cache[key] = value
        priority.insert(key, atIndex: 0)
        
        guard let first = priority.first else {
            return
        }
        
        key2node[key] = first
    }
    
}
