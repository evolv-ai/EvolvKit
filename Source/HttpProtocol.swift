//
//  HttpProtocol.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

public protocol HttpProtocol {
  
  /**
   - Performs a GET request to the **allocations endpoint** using the provided url.
   
   This call is asynchronous, the request is sent and a completable promise
   is returned. The promise is completed when the result of the request returns.
   
   - Parameters:
      - url: A valid url representing a call to the Participant API.
   
   - Returns: A response promise as a String
   */
  func get(_ url: URL) -> PromiseKit.Promise<String>
  
  /**
   - Performs a GET request to the **events endpoint** using the provided url.
   
   This call is asynchronous, the request is sent and a completable future
   is returned. The future is completed when the result of the request returns.
   
   - Parameters:
      - url: A valid url representing a call to the Participant API.
   
   - Returns: Void
   */
  
  func sendEvents(_ url: URL)
}
