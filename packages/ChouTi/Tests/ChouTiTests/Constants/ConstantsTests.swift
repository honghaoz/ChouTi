//
//  ConstantsTests.swift
//
//  Created by Honghao Zhang on 5/20/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

final class ConstantsTests: XCTestCase {

  func testIsDebug() {
    #if DEBUG
    expect(isDebug, "isDebug should be true in DEBUG mode") == true
    #else
    expect(isDebug, "isDebug should be false in non-DEBUG mode") == false
    #endif
  }

  func testIsMac() {
    #if os(macOS)
    expect(isMac, "isMac should be true on macOS") == true
    #else
    expect(isMac, "isMac should be false on non-macOS") == false
    #endif
  }

  func testIsIOS() {
    #if os(iOS)
    expect(isIOS, "isIOS should be true on iOS") == true
    #else
    expect(isIOS, "isIOS should be false on non-iOS") == false
    #endif
  }

  func testIsDebuggingUsingXcode() {
    #if DEBUG
    let expectedValue = isatty(STDERR_FILENO) == 1
    expect(isDebuggingUsingXcode) == expectedValue
    #endif
  }

  func testIsRunningAsRoot() {
    let expectedValue = getuid() == 0
    expect(isRunningAsRoot) == expectedValue
  }
}
