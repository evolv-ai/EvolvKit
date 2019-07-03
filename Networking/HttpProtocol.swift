//
//  HttpProtocol.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON


public protocol HttpProtocol {
  
  /**
   * Performs a GET request using the provided url.
   * <p>
   *     This call is asynchronous, the request is sent and a completable future
   *     is returned. The future is completed when the result of the request returns.
   *     The timeout of the request is determined in the implementation of the
   *     HttpClient.
   * </p>
   * @param url a valid url representing a call to the Participant API.
   * @return a response future
   */
  func get(url: URL) -> PromiseKit.Promise<String>
  
  /**
   * Performs a POST request using the provided url.
   * <p>
   *     This call is asynchronous, the request is sent and a completable future
   *     is returned. The future is completed when the result of the request returns.
   *     The timeout of the request is determined in the implementation of the
   *     HttpClient.
   * </p>
   * @param url a valid url representing a call to the Participant API.
   * @return a response future
   */
  func post(url: URL) -> PromiseKit.Promise<JSON>
  
}
