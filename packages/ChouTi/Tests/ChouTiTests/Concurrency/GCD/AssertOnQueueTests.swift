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
    let queue = DispatchQueue.make(label: "test")
    queue.sync {
      assertOnQueue(queue)
      assertOnQueue(queue, "should be on queue")
    }
  }

  func test_assertNotOnQueue() {
    let queue = DispatchQueue.make(label: "test")
    queue.sync {
      assertNotOnQueue(.main)
    }

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == #"Should be NOT on queue: com.apple.main-thread. Current queue label: "com.apple.main-thread". Message: Hey"#
    }
    assertNotOnQueue(.main, "Hey")
    Assert.resetTestAssertionFailureHandler()
  }

  func test_assertOnCooperativeQueue() {
    Task {
      assertOnCooperativeQueue()
    }
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message.contains("Should be on cooperative queue. Current thread:")) == true
    }
    assertOnCooperativeQueue()
    Assert.resetTestAssertionFailureHandler()
  }

  func test_assertNotOnCooperativeQueue() {
    let expectation = expectation(description: "")
    Task {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message.contains("Should NOT be on cooperative queue. Current thread: ")) == true
      }
      assertNotOnCooperativeQueue()
      Assert.resetTestAssertionFailureHandler()
      expectation.fulfill()
    }

    assertNotOnCooperativeQueue()
    waitForExpectations(timeout: 1)
  }
}
