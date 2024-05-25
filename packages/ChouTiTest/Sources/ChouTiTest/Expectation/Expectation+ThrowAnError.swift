//
//  Expectation+ThrowAnError.swift
//
//  Created by Honghao Zhang on 5/24/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the expression throws an error.
public struct ThrowAnErrorExpectation: Expectation {

  public typealias T = Any
  public typealias ThrownErrorType = Swift.Error

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

/// Make an expectation that the expression throws an error.
/// - Returns: An expectation.
public func throwAnError() -> ThrowAnErrorExpectation {
  ThrowAnErrorExpectation()
}
