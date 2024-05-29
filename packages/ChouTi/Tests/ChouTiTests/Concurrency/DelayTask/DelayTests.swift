//
//  DelayTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class DelayTests: XCTestCase {

  func test_delay_noRetain() {
    let expectation = expectation(description: "delayed task executed")

    var executed = false

    // no retain
    delay(0.1) {
      expect(Thread.isMainThread) == true
      executed = true
      expectation.fulfill()
    }

    expect(executed) == false
    waitForExpectations(timeout: 0.2) { _ in
      expect(executed) == true
    }
  }

  func test_delay_retain() {
    let expectation = expectation(description: "delayed task executed")

    var executed = false

    // retained task
    let task = delay(0.1) {
      expect(Thread.isMainThread) == true
      executed = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(executed) == false

    waitForExpectations(timeout: 0.2) { _ in
      expect(task.isCanceled) == false
      expect(task.isExecuted) == true
      expect(executed) == true
    }
  }

  func test_cancel() {
    let expectation = expectation(description: "delayed task should be canceled")
    expectation.assertForOverFulfill = true
    expectation.isInverted = true

    var executed = false
    let task = delay(0.1) {
      executed = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(executed) == false

    task.cancel()

    expect(task.isCanceled) == true
    expect(task.isExecuted) == false
    expect(executed) == false

    waitForExpectations(timeout: 0.15)

    expect(task.isCanceled) == true
    expect(task.isExecuted) == false
    expect(executed) == false
  }

  // MARK: - Early Execute

  func test_execute() {
    let expectation = expectation(description: "delayed task should be executed")
    expectation.assertForOverFulfill = true

    var value = false
    let task = delay(0.1) {
      value = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(value) == false

    task.execute()

    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(value) == true

    waitForExpectations(timeout: 0.15)
  }

  func test_execute_ifAlreadyCanceled() {
    let expectation = expectation(description: "delayed task should be executed")
    expectation.assertForOverFulfill = true
    expectation.isInverted = true

    var value = false
    let task = delay(0.1) {
      value = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(value) == false

    task.cancel()
    task.execute()

    expect(task.isCanceled) == true
    expect(task.isExecuted) == false
    expect(value) == false

    waitForExpectations(timeout: 0.15)
  }

  func test_execute_ifAlreadyExecuted() {
    let expectation = expectation(description: "delayed task should be executed")
    expectation.assertForOverFulfill = true

    var value = false
    let task = delay(0.1) {
      value = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(value) == false

    task.execute()
    task.execute()

    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(value) == true

    waitForExpectations(timeout: 0.15)
  }

  // MARK: - Edge Cases

  func test_invalidDelay_negative() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "delay seconds must be non-negative"
      expect(metadata) == ["delay": "-0.1"]
    }

    let expectation = expectation(description: "delayed task should be executed")

    var value = false
    let task = delay(-0.1) {
      value = true
      expectation.fulfill()
    }

    // invalid delay seconds leads to immediate execution
    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(value) == true

    waitForExpectations(timeout: 0.15)

    Assert.resetTestAssertionFailureHandler()
  }

  func test_invalidDelay_infinite() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "delay seconds must be finite"
      expect(metadata) == ["delay": "inf"]
    }

    let expectation = expectation(description: "delayed task should be executed")

    var value = false
    let task = delay(.infinity) {
      value = true
      expectation.fulfill()
    }

    // invalid delay seconds leads to immediate execution
    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(value) == true

    waitForExpectations(timeout: 0.15)

    Assert.resetTestAssertionFailureHandler()
  }

  // MARK: - Chained Task

  func testChainedTask() {
    var value = 1

    delay(0.1, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 2
    }
    .then(delay: 0.1, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 3
    }

    XCTAssertEqual(value, 1)

    delay(0.15, leeway: .zero) {
      XCTAssertEqual(value, 2)
    }

    delay(0.25, leeway: .zero) {
      XCTAssertEqual(value, 3)
    }
  }

  func testChainedTaskCancelled() {
    var value = 1

    let t1 = delay(0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 2
    }
    let t2 = t1.then(delay: 0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 3
    }

    XCTAssertEqual(value, 1)
    XCTAssertEqual(t1.isExecuted, false)
    XCTAssertEqual(t1.isCanceled, false)
    XCTAssertEqual(t2.isExecuted, false)
    XCTAssertEqual(t2.isCanceled, false)

    delay(0.1, leeway: .zero) {
      // cancel before t1 executes
      // this should cancel all dependent tasks
      t1.cancel()

      XCTAssertEqual(value, 1)

      XCTAssertEqual(t1.isExecuted, false)
      XCTAssertEqual(t1.isCanceled, true)
      XCTAssertEqual(t2.isExecuted, false)
      XCTAssertEqual(t2.isCanceled, true)
    }

    delay(0.3, leeway: .zero) {
      XCTAssertEqual(value, 1)

      XCTAssertEqual(t1.isExecuted, false)
      XCTAssertEqual(t1.isCanceled, true)
      XCTAssertEqual(t2.isExecuted, false)
      XCTAssertEqual(t2.isCanceled, true)
    }
  }

  func testChainedTaskCancelledInMiddle() {
    let expectation = XCTestExpectation(description: "")

    var value = 1

    let t1 = delay(0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 2
    }
    let t2 = t1.then(delay: 0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 3
    }
    let t3 = t2.then(delay: 0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 4
    }

    expect(value) == 1
    expect(t1.isExecuted) == false
    expect(t1.isCanceled) == false
    expect(t2.isExecuted) == false
    expect(t2.isCanceled) == false
    expect(t3.isExecuted) == false
    expect(t3.isCanceled) == false

    delay(0.1, leeway: .zero) {
      expect(t1.isExecuted) == false
      expect(t1.isCanceled) == false
      expect(t2.isExecuted) == false
      expect(t2.isCanceled) == false
      expect(t3.isExecuted) == false
      expect(t3.isCanceled) == false
    }

    delay(0.3, leeway: .zero) {
      expect(value) == 2

      expect(t1.isExecuted) == true // <--
      expect(t1.isCanceled) == false
      expect(t2.isExecuted) == false
      expect(t2.isCanceled) == false
      expect(t3.isExecuted) == false
      expect(t3.isCanceled) == false

      // cancel t2 should also cancel t3
      t2.cancel()

      expect(t1.isExecuted) == true
      expect(t1.isCanceled) == false
      expect(t2.isExecuted) == false
      expect(t2.isCanceled) == true // <--
      expect(t3.isExecuted) == false
      expect(t3.isCanceled) == true // <--

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }
}

// execute middle chained tasks
