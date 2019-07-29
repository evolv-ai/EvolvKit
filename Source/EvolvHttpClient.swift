//
//  EvolvHttpClient.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

public class EvolvHttpClient: HttpProtocol {
    
    let LOGGER = Log.logger
    
    public init() {}
    
    public func get(_ url: URL) -> Promise<String> {
        return Promise<String> { resolver -> Void in
            Alamofire.request(url)
                .validate()
                .responseString { response in
                    switch response.result {
                    case .success:
                        if let responseString = response.result.value {
                            self.LOGGER.log(.debug, message: String(describing: responseString))
                            resolver.fulfill(responseString)
                        }
                    case .failure(let error):
                        self.LOGGER.log(.error, message: String(describing: error))
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
            headers: headers).responseData { dataResponse in
                self.LOGGER.log(.debug, message: String(describing: dataResponse.request))
                self.LOGGER.log(.debug, message: String(describing: dataResponse.response))
                
                if dataResponse.response?.statusCode == 202 {
                    self.LOGGER.log(.debug, message: "Event has been emitted to Evolv")
                } else {
                    self.LOGGER.log(.error, message: "Error sending data to Evolv" +
                        " \(String(describing: dataResponse.response?.statusCode))")
                }
        }
    }
    
}
