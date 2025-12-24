//
//  TestWindowTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/8/25.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
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

#if !os(watchOS)

import ChouTiTest

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

class TestWindowTests: XCTestCase {

  // MARK: - Init Tests

  func test_init() {
    // when
    let window = TestWindow()

    // then
    expect(window.frame.width) == 500
    expect(window.frame.height) == 500
  }

  // MARK: - Content View Tests

  func test_contentView() {
    // given
    let window = TestWindow()

    // when
    let contentView = window.contentView()

    // then
    #if canImport(AppKit)
    expect(contentView) === window.contentView
    #elseif canImport(UIKit)
    expect(contentView.superview) === window
    expect(contentView.frame) == window.bounds
    expect(contentView.autoresizingMask) == [.flexibleWidth, .flexibleHeight]
    #endif
  }

  // MARK: - Layer Tests

  func test_layer() {
    // given
    let window = TestWindow()

    // then
    expect(window.layer) != nil
  }

  // MARK: - Main Window Tests

  #if canImport(AppKit)
  func test_mainWindow() {
    // given
    let window = TestWindow()

    // then
    expect(window.canBecomeMain) == true
  }

  // MARK: - Key Window Tests

  func test_keyWindow() {
    // given
    let window = TestWindow()

    // then
    expect(window.canBecomeKey) == true
    expect(window.isKeyWindow) == false

    // when makeKey
    window.makeKey()

    // then
    expect(window.isKeyWindow) == true

    // when resignKey
    window.resignKey()

    // then
    expect(window.isKeyWindow) == false

    // when set isKeyWindow to true
    window.isKeyWindow = true

    // then
    expect(window.isKeyWindow) == true

    // when set isKeyWindow to false
    window.isKeyWindow = false

    // then
    expect(window.isKeyWindow) == false
  }

  func test_makeKey_postsDidBecomeKeyNotification() {
    // given
    let window = TestWindow()
    let expectation = expectation(description: "didBecomeKeyNotification")
    var receivedNotification: Notification?

    let observer = NotificationCenter.default.addObserver(
      forName: NSWindow.didBecomeKeyNotification,
      object: window,
      queue: .main
    ) { notification in
      receivedNotification = notification
      expectation.fulfill()
    }

    defer {
      NotificationCenter.default.removeObserver(observer)
    }

    // when
    window.makeKey()

    // then
    wait(for: [expectation], timeout: 1.0)
    expect(receivedNotification) != nil
    expect(receivedNotification?.object as? TestWindow) === window
  }
  #endif
}

#endif
