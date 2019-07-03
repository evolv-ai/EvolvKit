//
//  EvolvAction.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public protocol EvolvAction {
  /**
   * Applies a given value to a set of instructions.
   * @param value any value that was requested
   */
  func apply<T>(value: T) -> Void
}
