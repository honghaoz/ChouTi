//
//  OptionalExpectation+beNil.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is `nil`.
public struct BeNilExpectation<T>: ExpressibleByNilLiteral, OptionalExpectation {

  public typealias ThrownErrorType = Never

  public init(nilLiteral: ()) {}

  public func evaluate(_ actualValue: T?) -> Bool {
    actualValue == nil
  }

  public var description: String {
    "be nil"
  }
}

/// Make an expectation that the actual value is `nil`.
/// - Returns: An expectation.
public func beNil<T>() -> BeNilExpectation<T> {
  nil
}

public extension OptionalExpression {

  static func == (lhs: Self, rhs: BeNilExpectation<T>) {
    lhs.to(rhs)
  }

  static func != (lhs: Self, rhs: BeNilExpectation<T>) {
    lhs.toNot(rhs)
  }
}
