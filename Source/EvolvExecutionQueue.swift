//
//  EvolvExecutionQueue.swift
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

class EvolvExecutionQueue {
    
    private let logger = EvolvLogger.shared
    
    private var queue: [EvolvExecutable] = []
    var count: Int {
        return queue.count
    }
    
    init() {}
    
    static let shared = EvolvExecutionQueue()
    
    func enqueue<T>(_ execution: EvolvExecution<T>) {
        queue.insert(execution, at: 0)
    }
    
    func executeAllWithValues(from rawAllocations: [EvolvRawAllocation]) throws {
        while !queue.isEmpty {
            guard let execution = queue.popLast() else {
                continue
            }
            
            do {
                try execution.execute(with: rawAllocations)
            } catch {
                logger.debug("There was an error retrieving the value of from the allocation.")
                
                execution.executeWithDefault()
            }
        }
    }
    
    func executeAllWithValuesFromDefaults() {
        while !queue.isEmpty {
            guard let execution = queue.popLast() else {
                continue
            }
            
            execution.executeWithDefault()
        }
    }
    
}
