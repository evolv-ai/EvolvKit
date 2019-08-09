//
//  EvolvLogger.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
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
    
    private func log(_ logLevel: EvolvLogLevel, item: Any?) {
        guard logLevel.rawValue <= self.logLevel.rawValue else {
            logMessage = nil
            return
        }
        
        guard let item = item else {
            logMessage = nil
            return
        }

        logMessage = String(format: "%@%@%@", basePrefix, logLevel.prefix(), "\(item)")
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let logMessage = self?.logMessage else {
                return
            }
            
            NSLog(logMessage)
        }
    }
    
}
