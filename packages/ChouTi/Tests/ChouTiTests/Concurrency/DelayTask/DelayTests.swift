//
//  DelayTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class DelayTests: XCTestCase {

  func testDelay() {
    let expectation = expectation(description: "delayed task executed")

    var stringToBeChanged = "start"

    // Task is retained in the expectation closure.
    let task = delay(0.1) {
      XCTAssertTrue(Thread.isMainThread)
      expectation.fulfill()
      stringToBeChanged = "end"
    }

    XCTAssertFalse(task.isCanceled)
    XCTAssertFalse(task.isExecuted)
    XCTAssertEqual(stringToBeChanged, "start")

    waitForExpectations(timeout: 0.2) { _ in
      XCTAssertFalse(task.isCanceled)
      XCTAssertTrue(task.isExecuted)
      XCTAssertEqual(stringToBeChanged, "end")
    }
  }

  func testSimpleDelay() {
    let expectation = expectation(description: "delayed task executed")

    var stringToBeChanged = "start"

    // No retain
    delay(0.1) {
      expectation.fulfill()
      stringToBeChanged = "end"
    }

    XCTAssertEqual(stringToBeChanged, "start")
    waitForExpectations(timeout: 0.2) { _ in
      XCTAssertEqual(stringToBeChanged, "end")
    }
  }

  func testSimpleDelayOnMain() {
    let expectation = expectation(description: "delayed task executed")

    var stringToBeChanged = "start"

    // No retain
    delay(0.1, queue: .main) {
      XCTAssertTrue(Thread.isMainThread)
      expectation.fulfill()
      stringToBeChanged = "end"
    }

    XCTAssertEqual(stringToBeChanged, "start")
    waitForExpectations(timeout: 0.2) { _ in
      XCTAssertEqual(stringToBeChanged, "end")
    }
  }

  func testCanceledTask() {
    var stringToBeChanged = "start"
    let task = delay(0.1) {
      stringToBeChanged = "end"
    }

    XCTAssertFalse(task.isCanceled)
    XCTAssertFalse(task.isExecuted)
    XCTAssertEqual(stringToBeChanged, "start")

    task.cancel()
    XCTAssertTrue(task.isCanceled)

    Thread.sleep(forTimeInterval: 0.15)

    XCTAssertTrue(task.isCanceled)
    XCTAssertFalse(task.isExecuted)
    XCTAssertEqual(stringToBeChanged, "start")
  }

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

  func testEarlyExecute() {
    let expectation = XCTestExpectation(description: "execute")
    expectation.assertForOverFulfill = true

    var executed: Bool = false
    let task = delay(0.1) {
      executed = true
      expectation.fulfill()
    }

    XCTAssertFalse(executed)
    XCTAssertFalse(task.isExecuted)

    task.execute()
    XCTAssertTrue(executed)
    XCTAssertTrue(task.isExecuted)

    wait(timeout: 0.2)
    wait(for: [expectation], timeout: 1)
  }
}
