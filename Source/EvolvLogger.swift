//
//  EvolvLogger.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public enum EvolvLogLevel: Int {
    case `default`
    case debug
    case error
}

struct EvolvLogger {
    
    static var shared = EvolvLogger()
    
    var logLevel: EvolvLogLevel = .default
    
    private init() {}
    
    func debug(_ message: String) {
        log(.debug, message: message)
    }
    
    func error(_ message: String) {
        log(.error, message: message)
    }
    
    private func log(_ logLevel: EvolvLogLevel, message: String) {
        guard logLevel.rawValue <= self.logLevel.rawValue else {
            return
        }
        
        var prefix = " "
        
        switch logLevel {
        case .debug:
            prefix = "[Debug] "
        case .error:
            prefix = "[Error] "
        default:
            break
        }
        
        DispatchQueue.global(qos: .utility).async {
            NSLog("[EvolvKit]%@%@", prefix, message)
        }
    }
    
}
