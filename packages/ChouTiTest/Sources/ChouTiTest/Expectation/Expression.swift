//
//  Expression.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/15/23.
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

import XCTest

/// An expression that can be evaluated.
public struct Expression<T> {

  /// The value getter.
  let value: () -> T

  /// The error thrown.
  let thrownError: Error?

  /// The human readable description of the expression.
  let description: () -> String?

  let file: StaticString

  let line: UInt

  init(value: @escaping () -> T, thrownError: Error?, description: @escaping () -> String?, file: StaticString, line: UInt) {
    self.value = value
    self.thrownError = thrownError
    self.description = description
    self.file = file
    self.line = line
  }

  // MARK: - To

  /// Evaluate the expression with an expectation.
  ///
  /// - Parameter expectation: The expectation to evaluate.
  public func to(_ expectation: some Expectation<T, Never>) {
    if let thrownError {
      XCTFail("expect not to throw error: \"\(thrownError)\"", file: file, line: line)
      return
    }

    let value = value()
    if !expectation.evaluate(value) {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(value)\") to \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"\(value)\" to \(expectation.description)", file: file, line: line)
      }
    }
  }

  /// Evaluate the expression to throw an error.
  ///
  /// If you want to evaluate the expression to throw any error, use `to(throwAnError())`.
  ///
  /// - Parameter expectation: The expectation to evaluate.
  public func to<E: Swift.Error>(_ expectation: ThrowErrorExpectation<E>) {
    guard let thrownError = thrownError else {
      if let description = description() {
        XCTFail("expect \"\(description)\" to throw an error", file: file, line: line)
      } else {
        XCTFail("expect to throw an error", file: file, line: line)
      }
      return
    }

    switch expectation.expectationType {
    case .anyError:
      break
    case .specificError(let expectedError, _):
      guard let thrownError = thrownError as? E else {
        if let description = description() {
          XCTFail("expect \"\(description)\"'s thrown error (\"\(thrownError)\") to be a type of \"\(E.self)\"", file: file, line: line)
        } else {
          XCTFail("expect \"\(thrownError)\" to be a type of \"\(E.self)\"", file: file, line: line)
        }
        return
      }
      if !expectation.evaluateError(thrownError) {
        if let description = description() {
          XCTFail("expect \"\(description)\"'s thrown error (\"\(thrownError)\") to be \"\(expectedError)\"", file: file, line: line)
        } else {
          XCTFail("expect \"\(thrownError)\" to be \"\(expectedError)\"", file: file, line: line)
        }
      }
    case .thrownErrorType:
      if !(thrownError is E) {
        if let description = description() {
          XCTFail("expect \"\(description)\"'s thrown error (\"\(thrownError)\") to be a type of \"\(E.self)\"", file: file, line: line)
        } else {
          XCTFail("expect \"\(thrownError)\" to be a type of \"\(E.self)\"", file: file, line: line)
        }
      }
    }
  }

  // MARK: - To Not

  /// Evaluate the expression to **not** meet the expectation.
  ///
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot(_ expectation: some Expectation<T, Never>) {
    if let thrownError {
      XCTFail("expect not to throw error: \"\(thrownError)\"", file: file, line: line)
      return
    }

    let value = value()
    if expectation.evaluate(value) {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(value)\") to not \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"\(value)\" to not \(expectation.description)", file: file, line: line)
      }
    }
  }

  /// Evaluate the expression to **not** throw an error.
  ///
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot<E: Swift.Error>(_ expectation: ThrowErrorExpectation<E>) {
    guard let thrownError else {
      // no thrown error, good
      return
    }

    switch expectation.expectationType {
    case .anyError:
      // expected to not throw any error, but got one, bad
      if let description = description() {
        XCTFail("expect \"\(description)\" to not throw an error, but got: \(thrownError)", file: file, line: line)
      } else {
        XCTFail("expect to not throw an error, but got: \(thrownError)", file: file, line: line)
      }
    case .specificError(let expectedError, _):
      guard let thrownError = thrownError as? E else {
        // got a different type of error, good
        return
      }
      if expectation.evaluateError(thrownError) {
        // got a matched error, bad
        if let description = description() {
          XCTFail("expect \"\(description)\"'s thrown error (\"\(thrownError)\") to not be \"\(expectedError)\"", file: file, line: line)
        } else {
          XCTFail("expect \"\(thrownError)\" to not be \"\(expectedError)\"", file: file, line: line)
        }
      }
    case .thrownErrorType:
      if thrownError is E {
        // got a matched type of error, bad
        if let description = description() {
          XCTFail("expect \"\(description)\"'s thrown error (\"\(thrownError)\") to not be a type of \"\(E.self)\"", file: file, line: line)
        } else {
          XCTFail("expect \"\(thrownError)\" to not be a type of \"\(E.self)\"", file: file, line: line)
        }
      }
    }
  }
}
