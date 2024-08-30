//
//  FailureCapturingTestCase.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/19/24.
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
