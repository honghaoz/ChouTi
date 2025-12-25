//
//  Skip.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/28/25.
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

/// Skips the remaining tests in a test method unconditionally.
/// - Parameters:
///   - message: A message for the skip.
///   - file: The file where the skip is occurred.
///   - line: The line number where the skip is occurred.
public func skip(_ message: @autoclosure () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws {
  throw XCTSkip(message(), file: file, line: line)
}

/// Skips remaining tests in a test method if the specified condition is met.
/// - Parameters:
///   - condition: A boolean value that determines whether to skip the remaining tests.
///   - message: A message for the skip.
///   - file: The file where the skip is occurred.
///   - line: The line number where the skip is occurred.
public func skipIf(_ condition: @autoclosure () throws -> Bool, _ message: @autoclosure () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws {
  try XCTSkipIf(condition(), message(), file: file, line: line)
}

/// Skips remaining tests in a test method unless the specified condition is met.
/// - Parameters:
///   - condition: A boolean value that determines whether to skip the remaining tests.
///   - message: A message for the skip.
///   - file: The file where the skip is occurred.
///   - line: The line number where the skip is occurred.
public func skipUnless(_ condition: @autoclosure () throws -> Bool, _ message: @autoclosure () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws {
  try XCTSkipUnless(condition(), message(), file: file, line: line)
}
