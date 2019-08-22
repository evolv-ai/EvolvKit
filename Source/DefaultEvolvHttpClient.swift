//
//  DefaultEvolvHttpClient.swift
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

import Alamofire
import PromiseKit

@objc public class DefaultEvolvHttpClient: NSObject, EvolvHttpClient {
    
    private let logger = EvolvLogger.shared
    
    public func get(_ url: URL) -> AnyPromise {
        return AnyPromise(Promise<String> { resolver -> Void in
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
        })
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
