//
//  EscapingExpression.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/24/24.
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

/// An expression that captures an escaping expression.
public struct EscapingExpression<T> {

  /// The expression.
  let expression: () throws -> T

  /// The human readable description of the expression.
  let description: () -> String?

  let file: StaticString

  let line: UInt

  init(expression: @escaping () throws -> T, description: @escaping () -> String?, file: StaticString, line: UInt) {
    self.expression = expression
    self.description = description
    self.file = file
    self.line = line
  }

  // MARK: - To

  /// Evaluate the expression with an expectation repeatedly until the expectation is satisfied or timeout.
  /// - Parameters:
  ///   - expectation: The expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventually(_ expectation: some Expectation<T, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    precondition(interval > 0, "interval must be greater than 0.")
    precondition(timeout > interval, "timeout must be greater than interval.")

    let testExpectation = XCTestExpectation()
    var lastValue: T?
    var thrownError: Error?
    repeating(interval: interval, timeout: timeout, queue: .main) { _ in
      do {
        let value = try expression()
        if expectation.evaluate(value) {
          testExpectation.fulfill()
          return true
        }

        lastValue = value
        return false
      } catch {
        thrownError = error
        return true
      }
    }

    let result = XCTWaiter.wait(for: [testExpectation], timeout: timeout)

    if let thrownError {
      if let description = description() {
        XCTFail("expression \"\(description)\" throws error: \(thrownError)", file: file, line: line)
      } else {
        XCTFail("expression throws error: \(thrownError)", file: file, line: line)
      }
      return
    }

    switch result {
    case .completed:
      break
    case .timedOut:
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(lastValue ??? "nil")\") to \(expectation.description) eventually", file: file, line: line)
      } else {
        XCTFail("expect \"\(lastValue ??? "nil")\" to \(expectation.description) eventually", file: file, line: line)
      }
    default:
      fatalError("Unexpected wait result: \(result)") // swiftlint:disable:this fatal_error
    }
  }

  // TODO: support throw error expectation
  // TODO: support throw error type expectation

  // MARK: - To Not

  /// Evaluate the expression with an expectation repeatedly until the expectation is **not** satisfied or timeout.
  /// - Parameters:
  ///   - expectation: The expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventuallyNot(_ expectation: some Expectation<T, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    precondition(interval > 0, "interval must be greater than 0.")
    precondition(timeout > interval, "timeout must be greater than interval.")

    let testExpectation = XCTestExpectation()
    var lastValue: T?
    var thrownError: Error?
    repeating(interval: interval, timeout: timeout, queue: .main) { _ in
      do {
        let value = try expression()
        if !expectation.evaluate(value) {
          testExpectation.fulfill()
          return true
        }

        lastValue = value
        return false
      } catch {
        thrownError = error
        return true
      }
    }

    let result = XCTWaiter.wait(for: [testExpectation], timeout: timeout)

    if let thrownError {
      if let description = description() {
        XCTFail("expression \"\(description)\" throws error: \(thrownError)", file: file, line: line)
      } else {
        XCTFail("expression throws error: \(thrownError)", file: file, line: line)
      }
      return
    }

    switch result {
    case .completed:
      break
    case .timedOut:
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(lastValue ??? "nil")\") to not \(expectation.description) eventually", file: file, line: line)
      } else {
        XCTFail("expect \"\(lastValue ??? "nil")\" to not \(expectation.description) eventually", file: file, line: line)
      }
    default:
      fatalError("Unexpected wait result: \(result)") // swiftlint:disable:this fatal_error
    }
  }
}
