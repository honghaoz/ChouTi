//
//  AssertOnMainThreadTests.swift
//
//  Created by Honghao Zhang on 6/2/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class AssertOnMainThreadTests: XCTestCase {

  func test_assertOnMainThread() {
    assertOnMainThread()

    DispatchQueue.global().sync {
      assertOnMainThread()
    }

    DispatchQueue.shared(qos: .utility).sync {
      assertOnMainThread()
    }

    let expectation = expectation(description: "on background thread")

    DispatchQueue.shared(qos: .utility).async {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message.contains("Should be on main thread. Current thread: <NSThread:")) == true
      }
      assertOnMainThread()
      Assert.resetTestAssertionFailureHandler()

      expectation.fulfill()
    }

    waitForExpectations(timeout: 0.5)
  }

  func test_assertNotOnMainThread() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message.contains("Should NOT be on main thread. Current thread: <"), message) == true
    }
    assertNotOnMainThread()
    Assert.resetTestAssertionFailureHandler()

    let expectation = expectation(description: "on background thread")

    DispatchQueue.shared(qos: .utility).async {
      assertNotOnMainThread()

      expectation.fulfill()
    }

    waitForExpectations(timeout: 0.5)
  }
}
