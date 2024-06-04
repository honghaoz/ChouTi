//
//  AssertOnQueueTests.swift
//
//  Created by Honghao Zhang on 6/2/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class AssertOnQueueTests: XCTestCase {

  func test_assertOnQueue() {
    let queue = DispatchQueue.make(label: "test")
    queue.sync {
      assertOnQueue(queue)
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
