//
//  Expectation+BeLessThanOrEqual.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is less than or equal to the expected value.
public struct BeLessThanOrEqualExpectation<T: Comparable>: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T

  public func evaluate(_ actualValue: T) -> Bool {
    actualValue <= value
  }

  public var description: String {
    "be less than or equal to \"\(value)\""
  }
}

/// Make an expectation that the actual value is less than or equal to the expected value.
/// - Parameter value: The expected value.
/// - Returns: An expectation.
public func beLessThanOrEqual<T>(to value: T) -> BeLessThanOrEqualExpectation<T> {
  BeLessThanOrEqualExpectation(value: value)
}

public extension Expression {

  static func <= (lhs: Self, rhs: T) where T: Comparable {
    lhs.to(BeLessThanOrEqualExpectation(value: rhs))
  }
}
