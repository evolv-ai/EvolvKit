//
//  EvolvLogger.swift
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

import Foundation

public enum EvolvLogLevel: Int {
    case info
    case debug
    case error
    
    func prefix() -> String {
        switch self {
        case .debug:
            return "[Debug] "
        case .error:
            return "[Error] "
        default:
            return " "
        }
    }
}

class EvolvLogger {
    
    static var shared = EvolvLogger()
    
    var logLevel: EvolvLogLevel = .info
    private let basePrefix: String = "[EvolvKit]"
    var logMessage: String?
    
    private init() {}
    
    func info(_ item: Any?) {
        log(.info, item: item)
    }
    
    func debug(_ item: Any?) {
        log(.debug, item: item)
    }
    
    func error(_ item: Any?) {
        log(.error, item: item)
    }
    
    private func getItemDescription(_ item: Any) -> String {
        var printedItem = ""
        print(item, separator: " ", to: &printedItem)
        let lastNewLineRange = printedItem.range(of: "\n", options: .backwards)
        return printedItem.replacingOccurrences(of: "\n", with: "", options: .backwards, range: lastNewLineRange)
    }
    
    private func log(_ logLevel: EvolvLogLevel, item: Any?) {
        guard logLevel.rawValue <= self.logLevel.rawValue else {
            logMessage = nil
            return
        }
        
        guard let item = item else {
            logMessage = nil
            return
        }
        
        logMessage = String(format: "%@%@%@", basePrefix, logLevel.prefix(), getItemDescription(item))
        
        guard let logMessage = logMessage else {
            return
        }
        
        NSLog(logMessage)
    }
    
}
