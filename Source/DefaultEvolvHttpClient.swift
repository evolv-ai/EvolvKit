//
//  DefaultEvolvHttpClient.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

public class DefaultEvolvHttpClient: EvolvHttpClient {
    
    private let logger = EvolvLogger.shared
    
    public init() {}
    
    public func get(_ url: URL) -> Promise<String> {
        return Promise<String> { resolver -> Void in
            Alamofire.request(url)
                .validate()
                .responseString { [weak self] response in
                    switch response.result {
                    case .success:
                        if let responseString = response.result.value {
                            self?.logger.debug(responseString)
                            resolver.fulfill(responseString)
                        }
                    case .failure(let error):
                        self?.logger.error(error.localizedDescription)
                        resolver.reject(error)
                    }
            }
        }
    }
    
    public func sendEvents(_ url: URL) {
        let headers = [
            "Content-Type": "application/json",
            "Host": "participants.evolv.ai"
        ]
        
        Alamofire.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default ,
            headers: headers)
            .validate(statusCode: 202...202)
            .responseString { [weak self] dataResponse in
                self?.logger.debug(dataResponse.request)
                self?.logger.debug(dataResponse.response)
                
                switch dataResponse.result {
                case .success:
                    self?.logger.debug("Event has been emitted to Evolv")
                case .failure(let error):
                    let description = "\(dataResponse.result.debugDescription)\n\(error)"
                    self?.logger.error(String(format: "Error sending data to Evolv (url: %@, description: %@)",
                                              dataResponse.request?.url?.absoluteString ?? "",
                                              description))
                }
        }
    }
    
}
