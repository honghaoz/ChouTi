//
//  OptionalExpression.swift
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
public struct OptionalExpression<T> {

  /// The value getter.
  let value: () -> T?

  /// The error thrown.
  let thrownError: Error?

  /// The human readable description of the expression.
  let description: () -> String?

  let file: StaticString

  let line: UInt

  init(value: @escaping () -> T?, thrownError: Error?, description: @escaping () -> String?, file: StaticString, line: UInt) {
    self.value = value
    self.thrownError = thrownError
    self.description = description
    self.file = file
    self.line = line
  }

  // MARK: - OptionalExpectation (To)

  /// Evaluate the expression with an expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func to(_ expectation: some OptionalExpectation<T, Never>) {
    if let thrownError {
      XCTFail("expect not to throw error: \"\(thrownError)\"", file: file, line: line)
      return
    }

    let value = value()
    if !expectation.evaluate(value) {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(value ??? "nil")\") to \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"\(value ??? "nil")\" to \(expectation.description)", file: file, line: line)
      }
    }
  }

  // MARK: - OptionalExpectation (To Not)

  /// Evaluate the expression to **not** meet the expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot(_ expectation: some OptionalExpectation<T, Never>) {
    if let thrownError {
      XCTFail("expect not to throw error: \"\(thrownError)\"", file: file, line: line)
      return
    }

    let value = value()
    if expectation.evaluate(value) {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(value ??? "nil")\") to not \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"\(value ??? "nil")\" to not \(expectation.description)", file: file, line: line)
      }
    }
  }

  // MARK: - Regular Expectation (To)

  /// Evaluate the expression with a regular (non-optional) expectation.
  ///
  /// The optional value will be automatically unwrapped. If the value is nil, the expectation fails.
  /// - Parameter expectation: The expectation to evaluate.
  public func to(_ expectation: some Expectation<T, Never>) {
    if let thrownError {
      XCTFail("expect not to throw error: \"\(thrownError)\"", file: file, line: line)
      return
    }

    let value = value()
    guard let unwrappedValue = value else {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"nil\") to \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"nil\" to \(expectation.description)", file: file, line: line)
      }
      return
    }

    if !expectation.evaluate(unwrappedValue) {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(unwrappedValue)\") to \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"\(unwrappedValue)\" to \(expectation.description)", file: file, line: line)
      }
    }
  }

  // MARK: - Regular Expectation (To Not)

  /// Evaluate the expression to **not** meet a regular (non-optional) expectation.
  ///
  /// The optional value will be automatically unwrapped. If the value is nil, the expectation succeeds.
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot(_ expectation: some Expectation<T, Never>) {
    if let thrownError {
      XCTFail("expect not to throw error: \"\(thrownError)\"", file: file, line: line)
      return
    }

    let value = value()
    guard let unwrappedValue = value else {
      // nil values automatically pass "toNot" checks for regular expectations
      return
    }

    if expectation.evaluate(unwrappedValue) {
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(unwrappedValue)\") to not \(expectation.description)", file: file, line: line)
      } else {
        XCTFail("expect \"\(unwrappedValue)\" to not \(expectation.description)", file: file, line: line)
      }
    }
  }
}

// MARK: - Comparison Operators

public extension OptionalExpression {

  /// Operator overload for `>` (greater than).
  static func > (lhs: Self, rhs: T) where T: Comparable {
    lhs.to(beGreaterThan(rhs))
  }

  /// Operator overload for `<` (less than).
  static func < (lhs: Self, rhs: T) where T: Comparable {
    lhs.to(beLessThan(rhs))
  }

  /// Operator overload for `>=` (greater than or equal).
  static func >= (lhs: Self, rhs: T) where T: Comparable {
    lhs.to(beGreaterThanOrEqual(to: rhs))
  }

  /// Operator overload for `<=` (less than or equal).
  static func <= (lhs: Self, rhs: T) where T: Comparable {
    lhs.to(beLessThanOrEqual(to: rhs))
  }
}
