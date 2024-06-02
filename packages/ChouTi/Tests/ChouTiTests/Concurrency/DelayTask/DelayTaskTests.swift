//
//  DelayTaskTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class DelayTaskTests: XCTestCase {

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

  func test_delay_noRetain_duration() {
    let expectation = expectation(description: "delayed task executed")

    var executed = false

    // no retain
    delay(.seconds(0.1)) {
      expect(Thread.isMainThread) == true
      executed = true
      expectation.fulfill()
    }

    expect(executed) == false
    waitForExpectations(timeout: 0.2) { _ in
      expect(executed) == true
    }
  }

  // MARK: - Cancel

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

  func test_double_cancel() {
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
    task.cancel() // will early return

    expect(task.isCanceled) == true
    expect(task.isExecuted) == false
    expect(executed) == false

    waitForExpectations(timeout: 0.15)

    expect(task.isCanceled) == true
    expect(task.isExecuted) == false
    expect(executed) == false
  }

  func test_cancel_ifAlreadyExecuted() {
    let expectation = expectation(description: "delayed task should be canceled")
    expectation.assertForOverFulfill = true

    var executed = false
    let task = delay(0.1) {
      executed = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(executed) == false

    task.execute()

    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(executed) == true

    task.cancel()

    expect(task.isCanceled) == false // already executed
    expect(task.isExecuted) == true
    expect(executed) == true

    waitForExpectations(timeout: 0.15)

    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(executed) == true
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

    wait(timeout: 0.15) // wait for the delay task to execute
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

  func test_queue_is_deallocated() {
    let expectation = expectation(description: "delayed task should be executed")
    expectation.assertForOverFulfill = true

    var value = false
    var queue: DispatchQueue? = DispatchQueue(label: "test_queue_is_deallocated")
    let task = delay(0.1, queue: queue!) { // swiftlint:disable:this force_unwrapping
      value = true
      expectation.fulfill()
    }

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(value) == false

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "execution queue is deallocated"
    }
    queue = nil
    task.execute()
    Assert.resetTestAssertionFailureHandler()

    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(value) == false

    waitForExpectations(timeout: 0.15)
  }

  // MARK: - Chained Task

  func test_chainedTask() {
    let task1Expectation = XCTestExpectation(description: "task1 should be executed")
    task1Expectation.assertForOverFulfill = true
    let task2Expectation = XCTestExpectation(description: "task2 should be executed")
    task2Expectation.assertForOverFulfill = true

    var value = 0
    let task = delay(0.1) {
      value = 1
      task1Expectation.fulfill()
    }

    let chainedTask = task.then(delay: 0.1) {
      value = 2
      task2Expectation.fulfill()
    }

    expect(value) == 0
    expect(task.isCanceled) == false
    expect(task.isExecuted) == false
    expect(chainedTask.isCanceled) == false
    expect(chainedTask.isExecuted) == false

    wait(for: [task1Expectation], timeout: 0.15)

    expect(value) == 1
    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(chainedTask.isCanceled) == false
    expect(chainedTask.isExecuted) == false

    wait(for: [task2Expectation], timeout: 0.15)

    expect(value) == 2
    expect(task.isCanceled) == false
    expect(task.isExecuted) == true
    expect(chainedTask.isCanceled) == false
    expect(chainedTask.isExecuted) == true
  }

  func test_chainedTask2() {
    var value = 0
    delay(0.1, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 1
    }
    .then(delay: 0.1, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 2
    }

    expect(value) == 0

    wait(timeout: 0.15)
    expect(value) == 1

    wait(timeout: 0.15)
    expect(value) == 2
  }

  func test_chainedTask_cancelBeforeExecuting() {
    var value = 1

    let t1 = delay(0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 2
    }
    let t2 = t1.then(delay: 0.2, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      value = 3
    }

    expect(value) == 1
    expect(t1.isExecuted) == false
    expect(t1.isCanceled) == false
    expect(t2.isExecuted) == false
    expect(t2.isCanceled) == false

    delay(0.1, leeway: .zero) {
      // cancel before t1 executes
      // this should cancel all dependent tasks
      t1.cancel()

      expect(value) == 1

      expect(t1.isExecuted) == false
      expect(t1.isCanceled) == true
      expect(t2.isExecuted) == false
      expect(t2.isCanceled) == true
    }

    delay(0.3, leeway: .zero) {
      expect(value) == 1

      expect(t1.isExecuted) == false
      expect(t1.isCanceled) == true
      expect(t2.isExecuted) == false
      expect(t2.isCanceled) == true
    }
  }

  func test_chainedTask_cancel_task2() {
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

  func test_chainedTask_earlyExecute() {
    let task2Expectation = XCTestExpectation(description: "task should be executed")
    task2Expectation.assertForOverFulfill = true

    let t1 = delay(0.1, leeway: .zero, queue: .shared(qos: .userInteractive)) {}

    t1.then(delay: 0.1, leeway: .zero, queue: .shared(qos: .userInteractive)) {
      task2Expectation.fulfill()
    }

    t1.execute()

    wait(for: [task2Expectation], timeout: 0.15) // task 2 schedules earlier
  }

  func test_chainedTask_with_leeway() {
    let expectation = XCTestExpectation(description: "task should be executed")
    expectation.assertForOverFulfill = true

    delay(0.1, leeway: .zero) {}
      .then(delay: 0.1, leeway: .zero) {
        expectation.fulfill()
      }

    wait(for: [expectation], timeout: 0.25)
  }

  func test_chainedTask_with_queue() {
    let expectation = XCTestExpectation(description: "task should be executed")
    expectation.assertForOverFulfill = true

    delay(0.1) {}
      .then(delay: 0.1, queue: .shared(qos: .userInteractive)) {
        expectation.fulfill()
      }

    wait(for: [expectation], timeout: 0.25)
  }

  func test_chainedTask_with_qos() {
    let expectation = XCTestExpectation(description: "task should be executed")
    expectation.assertForOverFulfill = true

    delay(0.1) {}
      .then(delay: 0.1, qos: .userInteractive, flags: [], queue: .shared(qos: .userInteractive)) {
        expectation.fulfill()
      }

    wait(for: [expectation], timeout: 0.25)
  }

  // MARK: - Async Task

  func test_delay_async() async throws {
    let delayedSeconds: TimeInterval = 0.5

    let start = mach_absolute_time()
    await delay(delayedSeconds)
    let endTime = mach_absolute_time()

    let elapsedTime = endTime.interval(since: start)

    expect(elapsedTime).to(beGreaterThan(delayedSeconds))

    let tolerance: TimeInterval = delayedSeconds / 10
    expect(elapsedTime).to(beLessThanOrEqual(to: delayedSeconds + tolerance))
  }

  func test_delay_async_duration() async throws {
    let delayedSeconds: TimeInterval = 0.5

    let start = mach_absolute_time()
    await delay(.milliseconds(delayedSeconds * 1000))
    let endTime = mach_absolute_time()

    let elapsedTime = endTime.interval(since: start)

    expect(elapsedTime).to(beGreaterThan(delayedSeconds))

    let tolerance: TimeInterval = delayedSeconds / 10
    expect(elapsedTime).to(beLessThanOrEqual(to: delayedSeconds + tolerance))
  }
}
