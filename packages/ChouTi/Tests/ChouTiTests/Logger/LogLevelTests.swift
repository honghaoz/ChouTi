//
//  LogLevelTests.swift
//
//  Created by Honghao Zhang on 5/20/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
@testable import ChouTi

final class LogLevelTests: XCTestCase {

  func testLogLevelEmoji() {
    XCTAssertEqual(LogLevel.debug.emoji, "🧻")
    XCTAssertEqual(LogLevel.info.emoji, "ℹ️")
    XCTAssertEqual(LogLevel.warning.emoji, "⚠️")
    XCTAssertEqual(LogLevel.error.emoji, "🛑")
  }

  func testLogLevelComparable() {
    // Test equality
    XCTAssertEqual(LogLevel.debug, LogLevel.debug)
    XCTAssertEqual(LogLevel.info, LogLevel.info)
    XCTAssertEqual(LogLevel.warning, LogLevel.warning)
    XCTAssertEqual(LogLevel.error, LogLevel.error)

    // Test less than
    XCTAssertTrue(LogLevel.debug < LogLevel.info)
    XCTAssertTrue(LogLevel.info < LogLevel.warning)
    XCTAssertTrue(LogLevel.warning < LogLevel.error)

    // Test greater than
    XCTAssertTrue(LogLevel.info > LogLevel.debug)
    XCTAssertTrue(LogLevel.warning > LogLevel.info)
    XCTAssertTrue(LogLevel.error > LogLevel.warning)
  }

  func testLogLevelComparableEdgeCases() {
    XCTAssertFalse(LogLevel.debug < LogLevel.debug)
    XCTAssertFalse(LogLevel.info < LogLevel.info)
    XCTAssertFalse(LogLevel.warning < LogLevel.warning)
    XCTAssertFalse(LogLevel.error < LogLevel.error)

    XCTAssertFalse(LogLevel.error < LogLevel.debug)
    XCTAssertFalse(LogLevel.error < LogLevel.info)
    XCTAssertFalse(LogLevel.error < LogLevel.warning)
  }
}
