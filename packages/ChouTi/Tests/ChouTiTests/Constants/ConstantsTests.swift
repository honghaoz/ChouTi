//
//  ConstantsTests.swift
//
//  Created by Honghao Zhang on 5/20/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

import ChouTi

final class ConstantsTests: XCTestCase {

  func testIsDebug() {
    #if DEBUG
    XCTAssertTrue(isDebug, "isDebug should be true in DEBUG mode")
    #else
    XCTAssertFalse(isDebug, "isDebug should be false in non-DEBUG mode")
    #endif
  }

  func testIsMac() {
    #if os(macOS)
    XCTAssertTrue(isMac, "isMac should be true on macOS")
    #else
    XCTAssertFalse(isMac, "isMac should be false on non-macOS")
    #endif
  }

  func testIsIOS() {
    #if os(iOS)
    XCTAssertTrue(isIOS, "isIOS should be true on iOS")
    #else
    XCTAssertFalse(isIOS, "isIOS should be false on non-iOS")
    #endif
  }

  func testIsDebuggingUsingXcode() {
    #if DEBUG
    let expectedValue = isatty(STDERR_FILENO) == 1
    XCTAssertEqual(isDebuggingUsingXcode, expectedValue, "isDebuggingUsingXcode should match the isatty(STDERR_FILENO) value")
    #endif
  }

  func testIsRunningAsRoot() {
    let expectedValue = getuid() == 0
    XCTAssertEqual(isRunningAsRoot, expectedValue, "isRunningAsRoot should match the getuid() == 0 value")
  }
}
