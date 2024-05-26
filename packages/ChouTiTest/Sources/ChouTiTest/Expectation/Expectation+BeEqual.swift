//
//  Expectation+BeEqual.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is equal to the expected value.
public struct BeEqualExpectation<T: Equatable>: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T

  public func evaluate(_ actualValue: T) -> Bool {
    actualValue == value
  }

  public var description: String {
    if let optionalValue = value as? OptionalProtocol {
      return "be equal to \"\(optionalValue.wrappedValueDescription)\""
    } else {
      return "be equal to \"\(value)\""
    }
  }
}

/// Make an expectation that the actual value is equal to the expected value.
/// - Parameter value: The expected value.
/// - Returns: An expectation.
public func beEqual<T>(to value: T) -> BeEqualExpectation<T> {
  BeEqualExpectation(value: value)
}

public extension Expression {

  static func == (lhs: Self, rhs: T) where T: Equatable {
    lhs.to(BeEqualExpectation(value: rhs))
  }

  static func != (lhs: Self, rhs: T) where T: Equatable {
    lhs.toNot(BeEqualExpectation(value: rhs))
  }
}
