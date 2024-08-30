//
//  unwrap.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

/// Unwrap an optional value from an expression.
///
/// - Parameters:
///   - expression: An expression to return value of `T?`.
///   - description: A human readable description of the expression.
///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you call this function.
/// - Returns: The unwrapped value.
public func unwrap<T>(_ expression: @autoclosure () throws -> T?, _ description: @autoclosure @escaping () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> T {
  if let value = try expression() {
    return value
  } else {
    if let description = description() {
      XCTFail("expect a non-nil value of \"\(description)\" (\(T.self))", file: file, line: line)
    } else {
      XCTFail("expect a non-nil value of type \(T.self)", file: file, line: line)
    }
    throw UnwrapError.nilValue
  }
}

public enum UnwrapError: Error {
  case nilValue
}

public extension Optional {

  /// Unwrap the optional value.
  ///
  /// - Parameters:
  ///   - description: A human readable description of the expression.
  ///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
  ///   - line: The line number where the failure occurs. The default is the line number where you call this function.
  /// - Returns: The unwrapped value.
  func unwrap(description: @autoclosure @escaping () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws -> Wrapped {
    try ChouTiTest.unwrap(self, description(), file: file, line: line)
  }
}
