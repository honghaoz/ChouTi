//
//  Expectation+ThrowError.swift
//
//  Created by Honghao Zhang on 11/11/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the expression throws an error.
public struct ThrowErrorExpectation<E: Swift.Error>: Expectation {

  public typealias T = Any
  public typealias ThrownErrorType = E

  let error: ThrownErrorType
  fileprivate let isErrorMatched: (ThrownErrorType) -> Bool

  public func evaluate(_ actualValue: T) -> Bool {
    assertionFailure("unexpected call")
    return false
  }

  public func evaluateError(_ thrownError: ThrownErrorType) -> Bool {
    isErrorMatched(thrownError)
  }

  public var description: String {
    assertionFailure("unexpected call")
    return ""
  }
}

/// Make an expectation that the expression throws an error.
/// - Parameter error: The error expect to throw.
/// - Returns: An expectation.
public func throwError<E: Swift.Error & Equatable>(_ error: E) -> ThrowErrorExpectation<E> {
  ThrowErrorExpectation(
    error: error,
    isErrorMatched: { thrownError in
      thrownError == error
    }
  )
}

/// Make an expectation that the expression throws an error.
/// - Parameters:
///   - error: The error expect to throw.
///   - isErrorMatched: A block to returns `true` if the expected error matches the thrown error.
/// - Returns: An expectation.
public func throwError<E: Swift.Error>(_ error: E, isErrorMatched: @escaping (_ expectedError: E, _ thrownError: E) -> Bool) -> ThrowErrorExpectation<E> {
  ThrowErrorExpectation(
    error: error,
    isErrorMatched: { thrownError in
      isErrorMatched(error, thrownError)
    }
  )
}
