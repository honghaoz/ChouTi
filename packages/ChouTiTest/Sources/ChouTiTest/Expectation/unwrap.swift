//
//  unwrap.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
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
      XCTFail("expect a non-nil value of type \(T.self) ", file: file, line: line)
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
