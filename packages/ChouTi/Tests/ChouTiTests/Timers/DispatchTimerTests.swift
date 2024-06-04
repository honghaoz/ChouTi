//
//  DispatchTimerTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

@testable import ChouTi

class DispatchTimerTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "test", qos: .userInteractive)

  // MARK: - Once

  func test_once() {
    let fireExpectation = expectation(description: "fire once")
    fireExpectation.assertForOverFulfill = true

    var fireCount = 0
    let queue = queue
    let timer = DispatchTimer(queue: queue) {
      expect(DispatchQueue.isOnQueue(queue)) == true
      fireCount += 1
      fireExpectation.fulfill()
    }
    timer.fire(after: 0.1, leeway: .zero)
    expect(timer.test.extraBlocks.count) == 0

    // additional blocks
    let fireExpectation2 = expectation(description: "fire once 2")
    fireExpectation2.assertForOverFulfill = true
    var fireCount2 = 0
    timer.addBlock(key: "key1") {
      fireCount2 += 1
      fireExpectation2.fulfill()
    }
    expect(timer.test.extraBlocks.count) == 1
    expect(timer.test.extraBlocks.hasKey("key1")) == true

    var fireCount3 = 0
    let fireExpectation3 = expectation(description: "fire once 3")
    fireExpectation3.assertForOverFulfill = true
    timer.addBlock(key: "key2") {
      fireCount3 += 1
      fireExpectation3.fulfill()
    }
    expect(timer.test.extraBlocks.count) == 2
    expect(timer.test.extraBlocks.hasKey("key1")) == true
    expect(timer.test.extraBlocks.hasKey("key2")) == true

    expect(fireCount) == 0
    expect(fireCount2) == 0
    expect(fireCount3) == 0

    delay(0.05, leeway: .zero) {
      expect(fireCount) == 0
      expect(fireCount2) == 0
      expect(fireCount3) == 0
    }

    waitForExpectations(timeout: 0.5)
  }

  // MARK: - Repeat

  func test_repeatTimer_fireImmediately() {
    var fireCount = 0
    let queue = queue
    let timer = DispatchTimer(queue: queue) {
      expect(DispatchQueue.isOnQueue(queue)) == true
      fireCount += 1
    }
    expect(timer.test.extraBlocks.count) == 0

    // additional blocks
    var fireCount2 = 0
    timer.addBlock(key: "key1") {
      fireCount2 += 1
    }
    expect(timer.test.extraBlocks.count) == 1
    expect(timer.test.extraBlocks.hasKey("key1")) == true

    var fireCount3 = 0
    timer.addBlock(key: "key2") {
      fireCount3 += 1
    }
    expect(timer.test.extraBlocks.count) == 2
    expect(timer.test.extraBlocks.hasKey("key1")) == true
    expect(timer.test.extraBlocks.hasKey("key2")) == true

    timer.fire(every: 0.3, leeway: .zero, fireImmediately: true)

    delay(0.05, leeway: .zero) {
      expect(fireCount) == 1
      expect(fireCount2) == 1
      expect(fireCount3) == 1
    }

    expect(fireCount).toEventually(beEqual(to: 2))
    expect(fireCount2).toEventually(beEqual(to: 2))
    expect(fireCount3).toEventually(beEqual(to: 2))

    // duration
    do {
      let timer = DispatchTimer(queue: queue) {}
      timer.fire(every: .nanoseconds(2e8), leeway: .zero, fireImmediately: true)
      expect(timer.interval) == 0.2
    }
  }

  func test_repeatingTimer_fireImmediately() {
    var fireCount = 0
    let queue = queue
    let timer = DispatchTimer.repeatingTimer(every: 0.3, isStrict: true, leeway: .zero, fireImmediately: true, queue: queue) {
      expect(DispatchQueue.isOnQueue(queue)) == true
      fireCount += 1
    }
    _ = timer

    delay(0.05, leeway: .zero) {
      expect(fireCount) == 1
    }

    expect(fireCount).toEventually(beEqual(to: 2))

    // duration
    do {
      let timer = DispatchTimer.repeatingTimer(every: .milliseconds(200)) {}
      expect(timer.interval) == 0.2
    }
  }

  // MARK: - Edge Cases

  func test_repeat_fireInterval_nonPositive() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "repeating duration should be greater than zero."
      expect(metadata) == ["interval": "-1.0"]
    }

    let timer = DispatchTimer(queue: .main, block: {})
    timer.fire(every: -1)
    expect(timer.interval) == nil

    Assert.resetTestAssertionFailureHandler()
  }

  func test_once_fireInterval_nonPositive() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "delay duration should be greater than zero."
      expect(metadata) == ["interval": "-2.1"]
    }

    let timer = DispatchTimer(queue: .main, block: {})
    timer.fire(after: -2.1)
    expect(timer.interval) == nil

    Assert.resetTestAssertionFailureHandler()
  }

  func test_repeat_fire_after_cancel() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Timer is already cancelled. You should create a new timer."
      expect(metadata) == [:]
    }

    let timer = DispatchTimer(queue: .main, block: {})
    timer.fire(every: 1)
    timer.cancel()
    expect(timer.interval) == 1

    timer.fire(every: 2)

    Assert.resetTestAssertionFailureHandler()
  }

  func test_once_fire_after_cancel() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Timer is already cancelled. You should create a new timer."
      expect(metadata) == [:]
    }

    let timer = DispatchTimer(queue: .main, block: {})
    timer.fire(after: 1)
    timer.cancel()
    expect(timer.interval) == 1

    timer.fire(after: 2)

    Assert.resetTestAssertionFailureHandler()
  }

  func test_repeat_fire_after_schedule() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Timer is already scheduled. You should create a new timer."
      expect(metadata) == [:]
    }

    let timer = DispatchTimer(queue: .main, block: {})
    timer.fire(every: 1)
    expect(timer.interval) == 1

    timer.fire(every: 2)
    expect(timer.interval) == 1

    Assert.resetTestAssertionFailureHandler()
  }

  func test_once_fire_after_schedule() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Timer is already scheduled. You should create a new timer."
      expect(metadata) == [:]
    }

    let timer = DispatchTimer(queue: .main, block: {})
    timer.fire(after: 1)
    expect(timer.interval) == 1

    timer.fire(after: 2)
    expect(timer.interval) == 1

    Assert.resetTestAssertionFailureHandler()
  }

  func test_addDuplicatedBlocks() {
    let timer = DispatchTimer(queue: .main, block: {})

    timer.addBlock(key: "key1") {}
    expect(timer.test.extraBlocks.count) == 1
    expect(timer.test.extraBlocks.hasKey("key1")) == true

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "duplicated block key"
      expect(metadata) == ["key": "key1"]
    }

    timer.addBlock(key: "key1") {}
    expect(timer.test.extraBlocks.count) == 1
    expect(timer.test.extraBlocks.hasKey("key1")) == true

    Assert.resetTestAssertionFailureHandler()
  }

  func test_removeMissingBlock() {
    let timer = DispatchTimer(queue: .main, block: {})
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "missing block key"
      expect(metadata) == ["key": "key1"]
    }
    timer.removeBlock(key: "key1")
    Assert.resetTestAssertionFailureHandler()
  }
}
