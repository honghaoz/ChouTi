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

  /// The type of the error expectation.
  enum ExpectationType {
    /// Expect the expression to throw any error.
    case anyError
    /// Expect the expression to throw a specific error.
    case specificError(E, isErrorMatched: (ThrownErrorType) -> Bool)
    /// Expect the expression to throw an error of the expected type.
    case thrownErrorType
  }

  let expectationType: ExpectationType

  public func evaluate(_ actualValue: T) -> Bool {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
  }

  public func evaluateError(_ thrownError: ThrownErrorType) -> Bool {
    switch expectationType {
    case .specificError(_, let isErrorMatched):
      return isErrorMatched(thrownError)
    case .anyError,
         .thrownErrorType:
      return true // not used
    }
  }

  public var description: String {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
  }
}

/// Make an expectation that the expression throws a specific error.
/// - Parameter error: The error expect to throw.
/// - Returns: An expectation.
public func throwError<E: Swift.Error & Equatable>(_ error: E) -> ThrowErrorExpectation<E> {
  ThrowErrorExpectation(
    expectationType: .specificError(error, isErrorMatched: { thrownError in
      thrownError == error
    })
  )
}

/// Make an expectation that the expression throws a specific error.
/// - Parameters:
///   - error: The error expect to throw.
///   - isErrorMatched: A block to returns `true` if the expected error matches the thrown error.
/// - Returns: An expectation.
public func throwError<E: Swift.Error>(_ error: E, isErrorMatched: @escaping (_ expectedError: E, _ thrownError: E) -> Bool) -> ThrowErrorExpectation<E> {
  ThrowErrorExpectation(
    expectationType: .specificError(error, isErrorMatched: { thrownError in
      isErrorMatched(error, thrownError)
    })
  )
}

/// Make an expectation that the expression throws any error.
/// - Returns: An expectation.
public func throwAnError() -> ThrowErrorExpectation<Swift.Error> {
  ThrowErrorExpectation(expectationType: .anyError)
}

/// Make an expectation that the expression throws an error of the expected type.
/// - Parameter error: The error type expect to throw.
/// - Returns: An expectation.
public func throwErrorOfType<E: Swift.Error>(_ error: E.Type) -> ThrowErrorExpectation<E> {
  ThrowErrorExpectation(expectationType: .thrownErrorType)
}
