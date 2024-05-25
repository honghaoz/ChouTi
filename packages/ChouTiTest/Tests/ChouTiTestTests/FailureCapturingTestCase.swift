//
//  FailureCapturingTestCase.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

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
    expect(failureMessage ?? "", file: file, line: line) == expectedMessage
    shouldRecord = false
  }

  func assertFailureContains(expectedMessage: String, file: StaticString = #filePath, line: UInt = #line) {
    shouldRecord = true
    expect((failureMessage ?? "").contains(expectedMessage), file: file, line: line) == true
    shouldRecord = false
  }
}
