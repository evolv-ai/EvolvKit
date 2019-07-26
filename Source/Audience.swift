//
//  Audience.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

protocol Function {
  associatedtype A
  associatedtype B
  func apply(one: A, two: B) -> Bool
}

public class Audience {
  
  public init () {}
  
}
