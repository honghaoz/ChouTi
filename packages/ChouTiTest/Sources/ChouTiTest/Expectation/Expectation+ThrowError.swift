//
//  Expectation+ThrowError.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/11/23.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation

/// An expectation that the expression throws an error.
public struct ThrowErrorExpectation<E: Swift.Error>: Expectation {

  public typealias T = Any
  public typealias ThrownErrorType = E

  /// The error expect to throw.
  let error: ThrownErrorType

  /// The block to check if the thrown error matches the expected error.
  fileprivate let isErrorMatched: (ThrownErrorType) -> Bool

  /// Whether expect to throw any error.
  let expectAnyError: Bool

  public func evaluate(_ actualValue: T) -> Bool {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
  }

  public func evaluateError(_ thrownError: ThrownErrorType) -> Bool {
    isErrorMatched(thrownError)
  }

  public var description: String {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
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
    },
    expectAnyError: false
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
    },
    expectAnyError: false
  )
}

/// Make an expectation that the expression throws an error.
/// - Returns: An expectation.
public func throwAnError() -> ThrowErrorExpectation<Swift.Error> {
  ThrowErrorExpectation(
    error: AnyError.anyError,
    isErrorMatched: { _ in
      return true
    },
    expectAnyError: true
  )
}

private enum AnyError: Swift.Error {
  case anyError
}
