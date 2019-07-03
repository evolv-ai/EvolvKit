//
//  EvolvHttpClient.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON


class EvolvHttpClient : HttpProtocol {
  
  func get(url: URL) -> Promise<String> {
    return Promise<String> { resolver -> Void in
      
      Alamofire.request(url)
        .validate()
        .responseString { response in
          switch response.result {
          case .success(let string):
            
            if let string = response.result.value {
              print("UR FETCHED JSON: \(string)")
              resolver.fulfill(string)
            }
          case .failure(let error):
            resolver.reject(error)
          }
      }
    }
  }
  
  // This is just for the emitter
  func post(url: URL) -> Promise<JSON> {
    return Promise<JSON> { resolver -> Void in
      
      Alamofire.request(url, method: .post, encoding: JSONEncoding.default)
        .validate()
        .responseJSON { response in
          switch response.result {
          case .success(let json):
            if let data = response.data {
              guard let json = try? JSON(data: data) else {
                resolver.reject("Error" as! Error)
                return
              }
              resolver.fulfill(json)
            }
          case .failure(let error):
            resolver.reject(error)
          }
      }
      
    }
  }
}
