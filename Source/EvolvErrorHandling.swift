//
//  EvolvErrorHandling.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

enum NetworkingError: String, Error {
    case invalidRequest = "Invalid request"
    case invalidUrl
    case response
    case data = "No data"
}

extension NetworkingError: LocalizedError {
    
    var errorDescription: String? {
        return NSLocalizedString(rawValue, comment: "")
    }
    
}

enum EvolvKeyError: String, Error {
    case errorMessage
    case elementFails = "Element Fails"
    case genomeEmpty = "Genome Empty"
    case mismatchTypes = "Mismatched Types"
    case keyError = "Key Error"
}

extension EvolvKeyError: LocalizedError {
    
    var errorDescription: String? {
        return NSLocalizedString(rawValue, comment: "")
    }
    
}
