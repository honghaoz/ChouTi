//
//  FailureCapturingTestCase.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

/// Helper class to capture XCTFail messages
class FailureCapturingTestCase: XCTestCase {

  private var failureMessages: [String] = []

  override func record(_ issue: XCTIssue) {
    // don't call super to prevent the issue be logged
    // super.record(issue)
    failureMessages.append(issue.compactDescription)
  }

  func assertFailure(expectedMessage: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(failureMessages.contains(expectedMessage), "Expected failure message not found", file: file, line: line)
  }
}
