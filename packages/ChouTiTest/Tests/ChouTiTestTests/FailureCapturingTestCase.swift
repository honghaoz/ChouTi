//
//  FailureCapturingTestCase.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

/// Helper class to capture XCTFail messages
class FailureCapturingTestCase: XCTestCase {

  private var shouldRecord: Bool = false

  private var failureMessage: String?

  override func record(_ issue: XCTIssue) {
    if shouldRecord {
      super.record(issue)
    }

    failureMessage = issue.compactDescription
  }

  func assertFailure(expectedMessage: String, file: StaticString = #filePath, line: UInt = #line) {
    shouldRecord = true
    XCTAssertEqual(failureMessage, expectedMessage, file: file, line: line)
    shouldRecord = false
  }

  func assertFailureContains(expectedMessage: String, file: StaticString = #filePath, line: UInt = #line) {
    shouldRecord = true
    XCTAssertTrue(failureMessage?.contains(expectedMessage) == true, file: file, line: line)
    shouldRecord = false
  }
}
