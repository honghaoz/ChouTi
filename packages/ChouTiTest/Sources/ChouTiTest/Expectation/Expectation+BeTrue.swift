//
//  Expectation+BeTrue.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is `true`.
public struct BeTrueExpectation: Expectation {

  public typealias T = Bool
  public typealias ThrownErrorType = Never

  public func evaluate(_ actualValue: Bool) -> Bool {
    actualValue
  }

  public var description: String {
    "be \"true\""
  }
}

/// Make an expectation that the actual value is `true`.
/// - Returns: An expectation.
public func beTrue() -> BeTrueExpectation {
  BeTrueExpectation()
}
