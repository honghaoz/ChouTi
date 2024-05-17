//
//  fail.swift
//
//  Created by Honghao Zhang on 10/22/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

/// Generate a test failure message.
/// - Parameters:
///   - message: A failure message.
///   - file: The file where the failure occurs. The default is the filename of the test case where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you call this function.
public func fail(_ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
  XCTFail(message, file: file, line: line)
}
