//
//  AssertOnMainThreadTests.swift
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

class AssertOnMainThreadTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "test-queue")

  func test_assertOnMainThread() {
    assertOnMainThread()

    DispatchQueue.global().sync {
      assertOnMainThread()
    }

    queue.sync {
      assertOnMainThread()
    }

    let expectation = expectation(description: "on background thread")

    queue.async {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should be on main thread. Message: \"\""
        expect(metadata["thread"]) == "\(Thread.current)"
        expect(metadata["queue"]) == "test-queue"
      }
      assertOnMainThread()
      Assert.resetTestAssertionFailureHandler()

      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should be on main thread. Message: \"Test message\""
        expect(metadata["thread"]) == "\(Thread.current)"
        expect(metadata["queue"]) == "test-queue"
      }
      assertOnMainThread("Test message")
      Assert.resetTestAssertionFailureHandler()

      expectation.fulfill()
    }

    waitForExpectations(timeout: 0.5)
  }

  func test_assertNotOnMainThread() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Should NOT be on main thread. Message: \"\""
      expect(metadata["thread"]) == "\(Thread.current)"
      expect(metadata["queue"]) == "com.apple.main-thread"
    }
    assertNotOnMainThread()
    Assert.resetTestAssertionFailureHandler()

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Should NOT be on main thread. Message: \"Test message\""
      expect(metadata["thread"]) == "\(Thread.current)"
      expect(metadata["queue"]) == "com.apple.main-thread"
    }
    assertNotOnMainThread("Test message")
    Assert.resetTestAssertionFailureHandler()

    let expectation = expectation(description: "on background thread")

    queue.async {
      assertNotOnMainThread()

      expectation.fulfill()
    }

    waitForExpectations(timeout: 0.5)
  }
}
