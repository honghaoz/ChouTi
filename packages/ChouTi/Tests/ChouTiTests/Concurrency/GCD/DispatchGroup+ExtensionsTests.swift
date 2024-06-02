//
//  DispatchGroup+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 6/2/24.
//  Copyright © 2024 ChouTi. All rights reserved.
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

  func testAsyncWithTimeout() {
    let expectation = self.expectation(description: "Async task with timeout should timeout")
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

    group.async(
      queue: .main,
      timeoutInterval: 0.1,
      timeout: {
        expectation.fulfill()
      },
      execute: {
        XCTFail("This block should not be called")
      }
    )

    waitForExpectations(timeout: 1, handler: nil)
  }

  func testAsyncWithTimeout_nonPositiveTimeout() {
    let expectation = self.expectation(description: "Async task with non-positive timeout should complete")
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

    group.async(
      queue: .main,
      timeoutInterval: -1,
      timeout: {},
      execute: {
        expectation.fulfill()
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
      DispatchQueue.global().async {
        usleep(100000) // 0.1 second
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
        usleep(100000) // 0.1 second
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
