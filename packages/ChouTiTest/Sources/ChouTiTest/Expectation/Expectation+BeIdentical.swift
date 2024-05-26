//
//  Expectation+BeIdentical.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is identical to the expected value.
public struct BeIdenticalExpectation<T: AnyObject>: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T

  public func evaluate(_ actualValue: T) -> Bool {
    actualValue === value
  }

  public var description: String {
    if let optionalValue = value as? OptionalProtocol {
      return "be identical to \"\(optionalValue.wrappedValueDescription)\""
    } else {
      return "be identical to \"\(value)\""
    }
  }
}

/// Make an expectation that the actual value is identical to the expected value.
/// - Parameter value: The expected value.
/// - Returns: An expectation.
public func beIdentical<T>(to value: T) -> BeIdenticalExpectation<T> {
  BeIdenticalExpectation(value: value)
}

public extension Expression {

  static func === (lhs: Self, rhs: T) where T: AnyObject {
    lhs.to(BeIdenticalExpectation(value: rhs))
  }

  static func !== (lhs: Self, rhs: T) where T: AnyObject {
    lhs.toNot(BeIdenticalExpectation(value: rhs))
  }
}
