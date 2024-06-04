//
//  LogLevelTests.swift
//
//  Created by Honghao Zhang on 5/20/24.
//  Copyright © 2024 ChouTi. All rights reserved.
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
