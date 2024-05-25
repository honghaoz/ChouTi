//
//  expect.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

/// Make an expression to be used to evaluate by an expectation.
///
/// - Parameters:
///   - expression: An expression to be evaluated.
///   - description: A human readable description of the expression.
///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you call this function.
/// - Returns: An expression.
public func expect<T>(_ expression: @autoclosure () throws -> T, _ description: @autoclosure @escaping () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) -> Expression<T> {
  do {
    let value = try expression()
    return Expression(value: { value }, thrownError: nil, description: description, file: file, line: line)
  } catch {
    return Expression(value: { fatalError("unexpected") }, thrownError: error, description: description, file: file, line: line)
  }
}

/// Make an expression to be used to evaluate by an expectation.
///
/// - Parameters:
///   - expression: An expression to be evaluated.
///   - description: A human readable description of the expression.
///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you call this function.
/// - Returns: An expression.
public func expect<T>(_ expression: @autoclosure () throws -> T?, _ description: @autoclosure @escaping () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) -> OptionalExpression<T> {
  do {
    let value = try expression()
    return OptionalExpression(value: { value }, thrownError: nil, description: description, file: file, line: line)
  } catch {
    return OptionalExpression(value: { fatalError("unexpected") }, thrownError: error, description: description, file: file, line: line)
  }
}

/// Make an expression to be used to evaluate by an expectation.
/// - Parameters:
///   - expression: An expression to be evaluated.
///   - description: A human readable description of the expression.
///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you call this function.
/// - Returns: An expression.
public func expect<T>(_ expression: @autoclosure @escaping () throws -> T, _ description: @autoclosure @escaping () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) -> EscapingExpression<T> {
  EscapingExpression(expression: expression, description: description, file: file, line: line)
}
