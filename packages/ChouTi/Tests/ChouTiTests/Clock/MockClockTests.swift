//
//  MockClockTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/31/24.
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

@testable import ChouTi

class MockClockTests: XCTestCase {

  func test_now() {
    let clock = MockClock(currentTime: 0)
    expect(clock.now()) == 0

    let clock2 = MockClock(currentTime: 1)
    expect(clock2.now()) == 1

    // invalid currentTime
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "currentTime must be greater than or equal to 0"
    }

    let clock3 = MockClock(currentTime: -1)
    expect(clock3.now()) == 0

    Assert.resetTestAssertionFailureHandler()
  }

  func test_advanceBy() {
    let clock = MockClock(currentTime: 0)
    expect(clock.now()) == 0

    clock.advance(by: 1)
    expect(clock.now()) == 1

    clock.advance(by: 1)
    expect(clock.now()) == 2

    // invalid seconds
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "seconds must be greater than or equal to 0"
    }

    clock.advance(by: -1)
    expect(clock.now()) == 2

    Assert.resetTestAssertionFailureHandler()
  }

  func test_advancTo() {
    let clock = MockClock(currentTime: 0)
    expect(clock.now()) == 0

    clock.advance(to: 1)
    expect(clock.now()) == 1

    // invalid time
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "time must be greater than current time"
    }

    clock.advance(to: 0)
    expect(clock.now()) == 1

    Assert.resetTestAssertionFailureHandler()
  }

  func test_delay_executed() {
    let clock = MockClock(currentTime: 0)
    let expectation = XCTestExpectation(description: "delay executed")

    clock.delay(1, queue: .main) {
      expect(Thread.isMainThread) == true
      expectation.fulfill()
    }

    expect(clock.test.scheduledTasks.count) == 1
    expect(try clock.test.scheduledTasks.first.unwrap().0) == 1

    clock.advance(by: 1)
    wait(for: [expectation], timeout: 1)

    expect(clock.test.scheduledTasks.count) == 0
    expect(clock.test.tokenStorage.count) == 0
  }

  func test_delay_cancelled() {
    let clock = MockClock(currentTime: 0)
    let expectation = XCTestExpectation(description: "delay executed")
    expectation.isInverted = true

    let token = clock.delay(1, queue: .main) {
      expect(Thread.isMainThread) == true
      expectation.fulfill()
    }

    token.cancel()
    expect(clock.test.scheduledTasks.count) == 0

    clock.advance(by: 1)
    wait(for: [expectation], timeout: 0.1)
  }

  func test_delay_duplicated_time() {
    let clock = MockClock(currentTime: 0)
    let expectation = XCTestExpectation(description: "delay executed")
    expectation.expectedFulfillmentCount = 2

    var callIndexes: [Int] = []
    clock.delay(1, queue: .main) {
      expect(Thread.isMainThread) == true
      callIndexes.append(1)
      expectation.fulfill()
    }

    clock.delay(1, queue: .main) {
      expect(Thread.isMainThread) == true
      callIndexes.append(2)
      expectation.fulfill()
    }

    expect(clock.test.scheduledTasks.count) == 2

    clock.advance(by: 1)

    wait(for: [expectation], timeout: 1)
    expect(callIndexes) == [1, 2]

    expect(clock.test.scheduledTasks.count) == 0
    expect(clock.test.tokenStorage.count) == 0
  }

  func test_delay_on_queue() {
    let clock = MockClock(currentTime: 0)
    let expectation = XCTestExpectation(description: "delay executed")
    expectation.expectedFulfillmentCount = 3

    var callIndexes: [Int] = []
    clock.delay(1, queue: .main) {
      expect(Thread.isMainThread) == true
      callIndexes.append(1)
      expectation.fulfill()
    }

    let queue = DispatchQueue.make(label: "test")

    clock.delay(1, queue: queue) {
      expect(DispatchQueue.currentQueueLabel) == "test"
      callIndexes.append(2)
      expectation.fulfill()
    }

    clock.delay(1, queue: .main) {
      expect(Thread.isMainThread) == true
      callIndexes.append(3)
      expectation.fulfill()
    }

    expect(clock.test.scheduledTasks.count) == 3
    expect(clock.test.tokenStorage.count) == 0

    clock.advance(by: 1)

    wait(for: [expectation], timeout: 1)

    expect(callIndexes) == [1, 3, 2]
    expect(clock.test.scheduledTasks.count) == 0
    expect(clock.test.tokenStorage.count) == 0
  }
}
