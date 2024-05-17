//
//  Expectation+BeFalse.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is `false`.
public struct BeFalseExpectation: Expectation {

  public typealias T = Bool
  public typealias ThrownErrorType = Never

  public func evaluate(_ actualValue: Bool) -> Bool {
    !actualValue
  }

  public var description: String {
    "be \"false\""
  }
}

/// Make an expectation that the actual value is `false`.
/// - Returns: An expectation.
public func beFalse() -> BeFalseExpectation {
  BeFalseExpectation()
}
