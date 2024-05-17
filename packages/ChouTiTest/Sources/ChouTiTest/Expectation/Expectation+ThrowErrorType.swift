//
//  Expectation+ThrowErrorType.swift
//
//  Created by Honghao Zhang on 11/11/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the expression throws an error of the expected type.
public struct ThrowErrorTypeExpectation<E: Swift.Error>: Expectation {

  public typealias T = Any
  public typealias ThrownErrorType = E

  public func evaluate(_ actualValue: T) -> Bool {
    assertionFailure("unexpected call")
    return false
  }

  public func evaluateError(_ thrownError: ThrownErrorType) -> Bool {
    assertionFailure("unexpected call")
    return false
  }

  public var description: String {
    assertionFailure("unexpected call")
    return ""
  }
}

/// Make an expectation that the expression throws an error of the expected type.
/// - Parameter error: The error type expect to throw.
/// - Returns: An expectation.
public func throwErrorOfType<E: Swift.Error>(_ error: E.Type) -> ThrowErrorTypeExpectation<E> {
  ThrowErrorTypeExpectation()
}

/// Make an expectation that the expression throws some error.
/// - Returns: An expectation.
public func throwSomeError() -> ThrowErrorTypeExpectation<Swift.Error> {
  ThrowErrorTypeExpectation()
}
