//
//  OptionalExpression.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
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

  // MARK: - To

  /// Evaluate the expression with an expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func to(_ expectation: some OptionalExpectation<T, Never>) {
    guard thrownError == nil else {
      fatalError("Impossible to throw error") // swiftlint:disable:this fatal_error
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

  // MARK: - To Not

  /// Evaluate the expression to **not** meet the expectation.
  /// - Parameter expectation: The expectation to evaluate.
  public func toNot(_ expectation: some OptionalExpectation<T, Never>) {
    guard thrownError == nil else {
      fatalError("Impossible to throw error") // swiftlint:disable:this fatal_error
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
}
