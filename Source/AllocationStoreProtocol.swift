//
//  AllocationStoreProtocol.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public protocol AllocationStoreProtocol {
  
  /**
   Retrieves a JsonArray.
   - SwiftyJSON is a required package for
   implementing the store. You can install SwiftyJSON here: https://cocoapods.org/pods/SwiftyJSON.
   
   - Retrieves a JsonArray converted to json using SwiftyJSON. JsonArray represents the participant's allocations.
   If there are no stored allocations, should return an empty SwiftyJSON array.
   - Parameters:
      - uid: The participant's unique id.
   - Returns: a SwiftyJSON array of allocation if one exists, else an empty SwiftyJSON array.
   */
  
  func get(_ participantId: String) -> [JSON]
  
  /**
   Stores a JsonArray.
   - Stores the given SwiftyJSON array.
   - Parameters:
      - uid: The participant's unique id.
      - allocations: The participant's allocations.
   */
  func put(_ participantId: String, _ allocations: [JSON])
}
