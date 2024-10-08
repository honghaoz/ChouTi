//
//  DispatchGroup+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 6/2/24.
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

import ChouTiTest

import ChouTi

class DispatchGroup_ExtensionsTests: XCTestCase {

  func testAsyncWithoutTimeout() {
    let expectation = self.expectation(description: "Async task without timeout should complete")
    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
      usleep(100000) // 0.1 second
      group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
      group.leave()
    }

    group.async(queue: .main) {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testAsyncWithTimeout_executed() {
    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
      usleep(50000) // 0.05 second
      group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
      group.leave()
    }

    let timeoutExpectation = self.expectation(description: "task should timeout")
    timeoutExpectation.isInverted = true

    let executeExpectation = self.expectation(description: "timed out task should not execute")
    executeExpectation.assertForOverFulfill = true

    group.async(
      queue: .main,
      timeoutInterval: 0.15,
      timeout: {
        expect(Thread.isMainThread) == true
        timeoutExpectation.fulfill()
      },
      execute: {
        expect(Thread.isMainThread) == true
        executeExpectation.fulfill()
      }
    )

    waitForExpectations(timeout: 0.25, handler: nil)
  }

  func testAsyncWithTimeout_timedOut() {
    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
      usleep(200000) // 0.2 second
      group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
      group.leave()
    }

    let timeoutExpectation = self.expectation(description: "should timeout")
    timeoutExpectation.assertForOverFulfill = true

    let executeExpectation = self.expectation(description: "should not execute")
    executeExpectation.isInverted = true

    group.async(
      queue: .main,
      timeoutInterval: 0.05,
      timeout: {
        expect(Thread.isMainThread) == true
        timeoutExpectation.fulfill()
      },
      execute: {
        expect(Thread.isMainThread) == true
        executeExpectation.fulfill()
      }
    )

    waitForExpectations(timeout: 0.3, handler: nil)
  }

  func testAsyncWithTimeout_nonPositiveTimeout() {
    let group = DispatchGroup()

    group.enter()
    DispatchQueue.global().async {
      usleep(50000) // 0.05 second
      group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
      group.leave()
    }

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Timeout interval should be greater than 0"
    }

    let timeoutExpectation = self.expectation(description: "task should timeout")
    timeoutExpectation.isInverted = true

    let executeExpectation = self.expectation(description: "timed out task should not execute")
    executeExpectation.assertForOverFulfill = true

    group.async(
      queue: .main,
      timeoutInterval: -1,
      timeout: {
        timeoutExpectation.fulfill()
      },
      execute: {
        executeExpectation.fulfill()
      }
    )
    Assert.resetTestAssertionFailureHandler()

    waitForExpectations(timeout: 0.2, handler: nil)
  }

  func testSyncWithoutTimeout() {
    let group = DispatchGroup()
    var isWorkExecuted = false

    group.enter()
    DispatchQueue.global().async {
      usleep(100000) // 0.1 second
      group.leave()
    }

    group.enter()
    DispatchQueue.global().async {
      group.leave()
    }

    group.sync {
      isWorkExecuted = true
    }

    expect(isWorkExecuted) == true
  }

  func testSyncWithTimeout() {
    // execute
    do {
      let group = DispatchGroup()
      var didTimeout = false
      var isWorkExecuted = false

      group.enter()
      DispatchQueue.global(qos: .userInteractive).async {
        usleep(50000) // 0.05 second
        group.leave()
      }

      group.sync(waitTimeout: .now() + 0.2, timeout: {
        didTimeout = true
      }) {
        isWorkExecuted = true
      }

      expect(didTimeout) == false
      expect(isWorkExecuted) == true
    }

    // time out
    do {
      let group = DispatchGroup()
      var didTimeout = false
      var isWorkExecuted = false

      group.enter()
      DispatchQueue.global().async {
        usleep(200000) // 0.2 second
        group.leave()
      }

      group.sync(waitTimeout: .now() + 0.1, timeout: {
        didTimeout = true
      }) {
        isWorkExecuted = true
      }

      expect(didTimeout) == true
      expect(isWorkExecuted) == false
    }
  }

  func testSyncWithWallTimeout() {
    // execute
    do {
      let group = DispatchGroup()
      var didTimeout = false
      var isWorkExecuted = false

      group.enter()
      DispatchQueue.global().async {
        usleep(50000) // 0.05 second
        group.leave()
      }

      group.sync(waitWallTimeout: .now() + 0.2, timeout: {
        didTimeout = true
      }) {
        isWorkExecuted = true
      }

      expect(didTimeout) == false
      expect(isWorkExecuted) == true
    }

    // time out
    do {
      let group = DispatchGroup()
      var didTimeout = false
      var isWorkExecuted = false

      group.enter()
      DispatchQueue.global().async {
        usleep(200000) // 0.2 second
        group.leave()
      }

      group.sync(waitWallTimeout: .now() + 0.1, timeout: {
        didTimeout = true
      }) {
        isWorkExecuted = true
      }

      expect(didTimeout) == true
      expect(isWorkExecuted) == false
    }
  }
}
