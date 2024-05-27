//
//  Expectation+BeGreaterThan.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is greater than the expected value.
public struct BeGreaterThanExpectation<T: Comparable>: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T

  public func evaluate(_ actualValue: T) -> Bool {
    actualValue > value
  }

  public var description: String {
    "be greater than \"\(value)\""
  }
}

/// Make an expectation that the actual value is greater than the expected value.
/// - Parameter value: The expected value.
/// - Returns: An expectation.
public func beGreaterThan<T>(_ value: T) -> BeGreaterThanExpectation<T> {
  BeGreaterThanExpectation(value: value)
}

public extension Expression {

  static func > (lhs: Self, rhs: T) where T: Comparable {
    lhs.to(BeGreaterThanExpectation(value: rhs))
  }
}
