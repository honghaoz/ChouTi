//
//  LogLevelTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/20/24.
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

import ChouTiTest

@testable import ChouTi

final class LogLevelTests: XCTestCase {

  func testLogLevelEmoji() {
    expect(LogLevel.debug.emoji) == "🧻"
    expect(LogLevel.info.emoji) == "ℹ️"
    expect(LogLevel.warning.emoji) == "⚠️"
    expect(LogLevel.error.emoji) == "🛑"
  }

  func testLogLevelComparable() {
    // Test equality
    expect(LogLevel.debug) == LogLevel.debug
    expect(LogLevel.info) == LogLevel.info
    expect(LogLevel.warning) == LogLevel.warning
    expect(LogLevel.error) == LogLevel.error

    // Test less than
    expect(LogLevel.debug).to(beLessThan(LogLevel.info))
    expect(LogLevel.info).to(beLessThan(LogLevel.warning))
    expect(LogLevel.warning).to(beLessThan(LogLevel.error))

    // Test greater than
    expect(LogLevel.info).to(beGreaterThan(LogLevel.debug))
    expect(LogLevel.warning).to(beGreaterThan(LogLevel.info))
    expect(LogLevel.error).to(beGreaterThan(LogLevel.warning))
  }

  func testLogLevelComparableEdgeCases() {
    expect(LogLevel.debug < LogLevel.debug) == false
    expect(LogLevel.info < LogLevel.info) == false
    expect(LogLevel.warning < LogLevel.warning) == false
    expect(LogLevel.error < LogLevel.error) == false

    expect(LogLevel.error < LogLevel.debug) == false
    expect(LogLevel.error < LogLevel.info) == false
    expect(LogLevel.error < LogLevel.warning) == false
  }
}
