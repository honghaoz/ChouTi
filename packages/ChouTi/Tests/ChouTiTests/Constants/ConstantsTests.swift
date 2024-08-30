//
//  ConstantsTests.swift
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
