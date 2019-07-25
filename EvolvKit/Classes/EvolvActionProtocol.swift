//
//  EvolvAction.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

public protocol EvolvActionProtocol {
  /**
   Applies a given value to a set of instructions.
   - Parameters:
      - value: Any value that was requested.
   */
  func apply<T>(value: T)
}
