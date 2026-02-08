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
  ///
  /// - Parameters:
  ///   - expectation: The expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventually(_ expectation: some Expectation<T, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    _toEventually(expectationEvaluate: expectation.evaluate, expectationDescription: { expectation.description }, interval: interval, timeout: timeout)
  }

  /// Evaluate the expression with an optional expectation repeatedly until the expectation is satisfied or timeout.
  ///
  /// - Parameters:
  ///   - expectation: The optional expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventually(_ expectation: some OptionalExpectation<T, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    _toEventually(expectationEvaluate: expectation.evaluate, expectationDescription: { expectation.description }, interval: interval, timeout: timeout)
  }

  /// Evaluate an optional expression with a regular (non-optional) expectation repeatedly until the expectation is satisfied or timeout.
  ///
  /// The optional value will be automatically unwrapped. If the value is `nil`, the expectation is treated as not met for that iteration.
  ///
  /// - Parameters:
  ///   - expectation: The regular expectation to evaluate against the unwrapped value.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventually<Wrapped>(_ expectation: some Expectation<Wrapped, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) where T == Wrapped? {
    _toEventually(
      expectationEvaluate: { actualValue in
        guard let actualValue else {
          return false
        }

        return expectation.evaluate(actualValue)
      },
      expectationDescription: { expectation.description },
      interval: interval,
      timeout: timeout
    )
  }

  /// The internal implementation of `toEventually` for both `Expectation` and `OptionalExpectation`.
  private func _toEventually(expectationEvaluate: @escaping (T) -> Bool, expectationDescription: () -> String, interval: TimeInterval, timeout: TimeInterval) {
    guard interval > 0 else {
      XCTFail("interval must be greater than 0.", file: file, line: line)
      return
    }
    guard timeout > interval else {
      XCTFail("timeout must be greater than interval.", file: file, line: line)
      return
    }

    let testExpectation = XCTestExpectation()
    var lastValue: T?
    var thrownError: Error?
    repeating(interval: interval, timeout: timeout, queue: .main) { _ in
      do {
        let value = try expression()
        if expectationEvaluate(value) {
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
      let formattedValue = formatValue(lastValue)
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(formattedValue)\") to \(expectationDescription()) eventually", file: file, line: line)
      } else {
        XCTFail("expect \"\(formattedValue)\" to \(expectationDescription()) eventually", file: file, line: line)
      }
    default:
      fatalError("Unexpected wait result: \(result)") // swiftlint:disable:this fatal_error
    }
  }

  /// Evaluate the expression to eventually throw an error.
  ///
  /// - Parameters:
  ///   - expectation: The expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventually<E: Swift.Error>(_ expectation: ThrowErrorExpectation<E>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    guard interval > 0 else {
      XCTFail("interval must be greater than 0.", file: file, line: line)
      return
    }
    guard timeout > interval else {
      XCTFail("timeout must be greater than interval.", file: file, line: line)
      return
    }

    let testExpectation = XCTestExpectation()
    var lastError: Error?
    repeating(interval: interval, timeout: timeout, queue: .main) { _ in
      do {
        _ = try expression()
        return false
      } catch {
        switch expectation.expectationType {
        case .anyError:
          testExpectation.fulfill()
          return true
        case .specificError,
             .thrownErrorType:
          if let thrownError = error as? E, expectation.evaluateError(thrownError) {
            testExpectation.fulfill()
            return true
          }
          lastError = error
          return false
        }
      }
    }

    let result = XCTWaiter.wait(for: [testExpectation], timeout: timeout)

    switch result {
    case .completed:
      break
    case .timedOut:
      switch expectation.expectationType {
      case .anyError:
        if let description = description() {
          XCTFail("expect \"\(description)\" to throw an error eventually", file: file, line: line)
        } else {
          XCTFail("expect to throw an error eventually", file: file, line: line)
        }
      case .specificError(let expectedError, _):
        if let lastError {
          if let description = description() {
            XCTFail("expect \"\(description)\"'s thrown error (\"\(lastError)\") to be \"\(expectedError)\" eventually", file: file, line: line)
          } else {
            XCTFail("expect thrown error (\"\(lastError)\") to be \"\(expectedError)\" eventually", file: file, line: line)
          }
        } else {
          if let description = description() {
            XCTFail("expect \"\(description)\" to throw error \"\(expectedError)\" eventually", file: file, line: line)
          } else {
            XCTFail("expect to throw error \"\(expectedError)\" eventually", file: file, line: line)
          }
        }
      case .thrownErrorType:
        if let lastError {
          if let description = description() {
            XCTFail("expect \"\(description)\"'s thrown error (\"\(lastError)\") to be a type of \"\(E.self)\" eventually", file: file, line: line)
          } else {
            XCTFail("expect thrown error (\"\(lastError)\") to be a type of \"\(E.self)\" eventually", file: file, line: line)
          }
        } else {
          if let description = description() {
            XCTFail("expect \"\(description)\" to throw an error of type \"\(E.self)\" eventually", file: file, line: line)
          } else {
            XCTFail("expect to throw an error of type \"\(E.self)\" eventually", file: file, line: line)
          }
        }
      }
    default:
      fatalError("Unexpected wait result: \(result)") // swiftlint:disable:this fatal_error
    }
  }

  // MARK: - To Not

  /// Evaluate the expression with an expectation repeatedly until the expectation is **not** satisfied or timeout.
  ///
  /// - Parameters:
  ///   - expectation: The expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventuallyNot(_ expectation: some Expectation<T, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    _toEventuallyNot(expectationEvaluate: expectation.evaluate, expectationDescription: { expectation.description }, interval: interval, timeout: timeout)
  }

  /// Evaluate the expression with an optional expectation repeatedly until the expectation is **not** satisfied or timeout.
  ///
  /// - Parameters:
  ///   - expectation: The optional expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventuallyNot(_ expectation: some OptionalExpectation<T, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    _toEventuallyNot(expectationEvaluate: expectation.evaluate, expectationDescription: { expectation.description }, interval: interval, timeout: timeout)
  }

  /// Evaluate an optional expression with a regular (non-optional) expectation repeatedly until the expectation is **not** satisfied or timeout.
  ///
  /// The optional value will be automatically unwrapped. If the value is `nil`, it is treated as "not meeting" the expectation for that iteration.
  ///
  /// - Parameters:
  ///   - expectation: The regular expectation to evaluate against the unwrapped value.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventuallyNot<Wrapped>(_ expectation: some Expectation<Wrapped, Never>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) where T == Wrapped? {
    _toEventuallyNot(
      expectationEvaluate: { actualValue in
        guard let actualValue else {
          return false
        }

        return expectation.evaluate(actualValue)
      },
      expectationDescription: { expectation.description },
      interval: interval,
      timeout: timeout
    )
  }

  /// The internal implementation of `toEventuallyNot` for both `Expectation` and `OptionalExpectation`.
  private func _toEventuallyNot(expectationEvaluate: @escaping (T) -> Bool, expectationDescription: () -> String, interval: TimeInterval, timeout: TimeInterval) {
    guard interval > 0 else {
      XCTFail("interval must be greater than 0.", file: file, line: line)
      return
    }
    guard timeout > interval else {
      XCTFail("timeout must be greater than interval.", file: file, line: line)
      return
    }

    let testExpectation = XCTestExpectation()
    var lastValue: T?
    var thrownError: Error?
    repeating(interval: interval, timeout: timeout, queue: .main) { _ in
      do {
        let value = try expression()
        if !expectationEvaluate(value) {
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
      let formattedValue = formatValue(lastValue)
      if let description = description() {
        XCTFail("expect \"\(description)\" (\"\(formattedValue)\") to not \(expectationDescription()) eventually", file: file, line: line)
      } else {
        XCTFail("expect \"\(formattedValue)\" to not \(expectationDescription()) eventually", file: file, line: line)
      }
    default:
      fatalError("Unexpected wait result: \(result)") // swiftlint:disable:this fatal_error
    }
  }

  /// Evaluate the expression to eventually not throw an error.
  ///
  /// - Parameters:
  ///   - expectation: The expectation to evaluate.
  ///   - interval: The repeating interval to evaluate the expression. Default is 0.01 seconds.
  ///   - timeout: The timeout to stop evaluating the expression. Default is 3 seconds.
  public func toEventuallyNot<E: Swift.Error>(_ expectation: ThrowErrorExpectation<E>, interval: TimeInterval = 0.01, timeout: TimeInterval = 3) {
    guard interval > 0 else {
      XCTFail("interval must be greater than 0.", file: file, line: line)
      return
    }
    guard timeout > interval else {
      XCTFail("timeout must be greater than interval.", file: file, line: line)
      return
    }

    let testExpectation = XCTestExpectation()
    var lastError: Error?
    repeating(interval: interval, timeout: timeout, queue: .main) { _ in
      do {
        _ = try expression()
        testExpectation.fulfill()
        return true
      } catch {
        switch expectation.expectationType {
        case .anyError:
          // expected to not throw any error, but got one, bad
          lastError = error
          return false
        case .specificError,
             .thrownErrorType:
          if let thrownError = error as? E, expectation.evaluateError(thrownError) {
            lastError = error
            return false
          }
          testExpectation.fulfill()
          return true
        }
      }
    }

    let result = XCTWaiter.wait(for: [testExpectation], timeout: timeout)

    switch result {
    case .completed:
      break
    case .timedOut:
      if let lastError {
        switch expectation.expectationType {
        case .anyError:
          if let description = description() {
            XCTFail("expect \"\(description)\" to not throw an error eventually, but got: \(lastError)", file: file, line: line)
          } else {
            XCTFail("expect to not throw an error eventually, but got: \(lastError)", file: file, line: line)
          }
        case .specificError(let expectedError, _):
          if let description = description() {
            XCTFail("expect \"\(description)\" to not throw error \"\(expectedError)\" eventually", file: file, line: line)
          } else {
            XCTFail("expect to not throw error \"\(expectedError)\" eventually", file: file, line: line)
          }
        case .thrownErrorType:
          if let description = description() {
            XCTFail("expect \"\(description)\"'s thrown error (\"\(lastError)\") to not be a type of \"\(E.self)\" eventually", file: file, line: line)
          } else {
            XCTFail("expect thrown error (\"\(lastError)\") to not be a type of \"\(E.self)\" eventually", file: file, line: line)
          }
        }
      }
    default:
      fatalError("Unexpected wait result: \(result)") // swiftlint:disable:this fatal_error
    }
  }

  // MARK: - Helper

  /// Helper function to format a value for display, unwrapping nested optionals.
  private func formatValue(_ value: T?) -> String {
    guard let value = value else {
      return "nil" // impossible as the lastValue is always non-nil since repeating interval is always less than timeout, so when the timeout is reached, the lastValue is always non-nil
    }

    // check if the value is an optional using Mirror
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
      if mirror.children.isEmpty {
        // the optional is .none
        return "nil"
      } else if let (_, wrappedValue) = mirror.children.first {
        // the optional is .some, get the wrapped value
        return "\(wrappedValue)"
      }
    }

    return "\(value)"
  }
}
