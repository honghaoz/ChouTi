//
//  OptionalExpectation+BeIdentical.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is identical to the expected value.
public struct BeIdenticalOptionalExpectation<T: AnyObject>: OptionalExpectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T?

  public func evaluate(_ actualValue: T?) -> Bool {
    actualValue === value
  }

  public var description: String {
    if let value {
      return "be identical to \"\(value)\""
    } else {
      return "be identical to nil"
    }
  }
}

/// Make an expectation that the actual value is identical to the expected value.
/// - Parameter value: The expected value.
/// - Returns: An expectation.
public func beIdentical<T>(to value: T?) -> BeIdenticalOptionalExpectation<T> where T: AnyObject {
  BeIdenticalOptionalExpectation(value: value)
}

public extension OptionalExpression {

  static func === (lhs: Self, rhs: T?) where T: AnyObject {
    if let rhs {
      lhs.to(BeIdenticalOptionalExpectation(value: rhs))
    } else {
      lhs.to(beNil())
    }
  }

  static func !== (lhs: Self, rhs: T?) where T: AnyObject {
    if let rhs {
      lhs.toNot(BeIdenticalOptionalExpectation(value: rhs))
    } else {
      lhs.toNot(beNil())
    }
  }
}
