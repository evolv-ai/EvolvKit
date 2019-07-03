//
//  AllocationStoreProtocol.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

// This is the inerface for the client
public protocol AllocationStoreProtocol {
  
  /**
   * Retrieves a JsonArray.
   * <p>
   *     Retrieves a JsonArray that represents the participant's allocations.
   *     If there are no stored allocations, should return an empty JsonArray.
   * </p>
   * @param uid the participant's unique id
   * @return an allocation if one exists else an empty JsonArray
   */
  
  func get(uid: String) -> [JSON]? // FIXME: can this ever return an empty string?
  
  /**
   * Stores a JsonArray.
   * <p>
   *     Stores the given JsonArray.
   * </p>
   * @param uid the participant's unique id
   * @param allocations the participant's allocations
   */
  func set(uid: String, allocations: [JSON]) -> ()
}
