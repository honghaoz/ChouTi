//
//  expect.swift
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
