//
//  Expression.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
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
  /// - Parameter expectation: The expectation to evaluate.
  public func to(_ expectation: some Expectation<T, Never>) {
    if let thrownError {
      if let description = description() {
        XCTFail("expression \"\(description)\" throws error: \(thrownError)", file: file, line: line)
      } else {
        XCTFail("expression throws error: \(thrownError)", file: file, line: line)
      }
    } else {
      let value = value()
      if !expectation.evaluate(value) {
        if let description = description() {
          XCTFail("expect \"\(description)\" (\"\(value)\") to \(expectation.description)", file: file, line: line)
        } else {
          XCTFail("expect \"\(value)\" to \(expectation.description)", file: file, line: line)
        }
      }
    }
  }

  /// Evaluate the expression with an expectation.
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
    guard let thrownError = thrownError as? E else {
      if let description = description() {
        XCTFail("expect \"\(description)\" error (\"\(thrownError)\") to be a type of \"\(E.self)\"", file: file, line: line)
      } else {
        XCTFail("expect \"\(thrownError)\" to be a type of \"\(E.self)\"", file: file, line: line)
      }
      return
    }

    if !expectation.evaluateError(thrownError) {
      if let description = description() {
        XCTFail("expect \"\(description)\" error (\"\(thrownError)\") to be \"\(expectation.error)\"", file: file, line: line)
      } else {
        XCTFail("expect \"\(thrownError)\" to be \"\(expectation.error)\"", file: file, line: line)
      }
    }
  }

  /// Evaluate the expression with an expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func to<E: Swift.Error>(_ expectation: ThrowErrorTypeExpectation<E>) {
    guard let thrownError = thrownError else {
      if let description = description() {
        XCTFail("expect \"\(description)\" to throw an error", file: file, line: line)
      } else {
        XCTFail("expect to throw an error", file: file, line: line)
      }
      return
    }
    if !(thrownError is E) {
      if let description = description() {
        XCTFail("expect \"\(description)\" error (\"\(thrownError)\") to be a type of \"\(E.self)\"", file: file, line: line)
      } else {
        XCTFail("expect \"\(thrownError)\" to be a type of \"\(E.self)\"", file: file, line: line)
      }
    }
  }

  // MARK: - To Not

  /// Evaluate the expression to **not** meet the expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot(_ expectation: some Expectation<T, Never>) {
    if let thrownError {
      if let description = description() {
        XCTFail("expression \"\(description)\" throws error: \(thrownError)", file: file, line: line)
      } else {
        XCTFail("expression throws error: \(thrownError)", file: file, line: line)
      }
    } else {
      let value = value()
      if expectation.evaluate(value) {
        if let description = description() {
          XCTFail("expect \"\(description)\" (\"\(value)\") to not \(expectation.description)", file: file, line: line)
        } else {
          XCTFail("expect \"\(value)\" to not \(expectation.description)", file: file, line: line)
        }
      }
    }
  }

  /// Evaluate the expression to **not** meet the expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot<E: Swift.Error>(_ expectation: ThrowErrorExpectation<E>) {
    guard let thrownError = thrownError as? E else {
      return
    }

    if expectation.evaluateError(thrownError) {
      if let description = description() {
        XCTFail("expect \"\(description)\" error (\"\(thrownError)\") to not be \"\(expectation.error)\"", file: file, line: line)
      } else {
        XCTFail("expect \"\(thrownError)\" to not be \"\(expectation.error)\"", file: file, line: line)
      }
    }
  }

  /// Evaluate the expression to **not** meet the expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot<E: Swift.Error>(_ expectation: ThrowErrorTypeExpectation<E>) {
    guard let thrownError = thrownError else {
      return
    }
    if thrownError is E {
      if let description = description() {
        XCTFail("expect \"\(description)\" error (\"\(thrownError)\") to not be a type of \"\(E.self)\"", file: file, line: line)
      } else {
        XCTFail("expect \"\(thrownError)\" to not be a type of \"\(E.self)\"", file: file, line: line)
      }
    }
  }
}
