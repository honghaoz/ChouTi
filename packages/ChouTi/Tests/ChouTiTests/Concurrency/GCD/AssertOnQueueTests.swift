//
//  AssertOnQueueTests.swift
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

class AssertOnQueueTests: XCTestCase {

  func test_assertOnQueue() {
    let queue = DispatchQueue.make(label: "queue")
    let queue2 = DispatchQueue.make(label: "queue2")
    queue.sync {
      assertOnQueue(queue)
      assertOnQueue(queue, "should be on queue")

      // no message
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should be on queue: queue2. Message: \"\""
        expect(metadata["queue"]) == "queue"
        expect(metadata["thread"]) == "\(Thread.current)"
      }
      assertOnQueue(queue2)
      Assert.resetTestAssertionFailureHandler()

      // with message
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should be on queue: queue2. Message: \"Test message\""
        expect(metadata["queue"]) == "queue"
        expect(metadata["thread"]) == "\(Thread.current)"
      }
      assertOnQueue(queue2, "Test message")
      Assert.resetTestAssertionFailureHandler()
    }
  }

  func test_assertNotOnQueue() {
    let queue = DispatchQueue.make(label: "queue")
    let queue2 = DispatchQueue.make(label: "queue2")
    queue.sync {
      assertNotOnQueue(queue2)
      assertNotOnQueue(queue2, "should not be on queue")

      // no message
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should NOT be on queue: queue. Message: \"\""
        expect(metadata["queue"]) == "queue"
        expect(metadata["thread"]) == "\(Thread.current)"
      }
      assertNotOnQueue(queue)
      Assert.resetTestAssertionFailureHandler()

      // with message
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should NOT be on queue: queue. Message: \"Test message\""
        expect(metadata["queue"]) == "queue"
        expect(metadata["thread"]) == "\(Thread.current)"
      }
      assertNotOnQueue(queue, "Test message")
      Assert.resetTestAssertionFailureHandler()
    }
  }

  func test_assertOnCooperativeQueue() {
    Task {
      assertOnCooperativeQueue()
    }

    // no message
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Should be on cooperative queue. Message: \"\""
      expect(metadata["queue"]) == "com.apple.main-thread"
      expect(metadata["thread"]) == "\(Thread.current)"
    }
    assertOnCooperativeQueue()
    Assert.resetTestAssertionFailureHandler()

    // with message
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Should be on cooperative queue. Message: \"Test message\""
      expect(metadata["queue"]) == "com.apple.main-thread"
      expect(metadata["thread"]) == "\(Thread.current)"
    }
    assertOnCooperativeQueue("Test message")
    Assert.resetTestAssertionFailureHandler()
  }

  func test_assertNotOnCooperativeQueue() {
    let expectation = expectation(description: "")
    Task {
      // no message
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should NOT be on cooperative queue. Message: \"\""
        expect(metadata["queue"]) == "\(DispatchQueue.currentQueueLabel)"
        expect(metadata["thread"]) == "\(Thread.current)"
      }
      assertNotOnCooperativeQueue()
      Assert.resetTestAssertionFailureHandler()

      // with message
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Should NOT be on cooperative queue. Message: \"Test message\""
        expect(metadata["queue"]) == "\(DispatchQueue.currentQueueLabel)"
        expect(metadata["thread"]) == "\(Thread.current)"
      }
      assertNotOnCooperativeQueue("Test message")
      Assert.resetTestAssertionFailureHandler()

      expectation.fulfill()
    }

    assertNotOnCooperativeQueue()
    waitForExpectations(timeout: 1)
  }
}
