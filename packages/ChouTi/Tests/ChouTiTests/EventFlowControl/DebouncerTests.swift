//
//  DebouncerTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/19/21.
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

class LeadingDebouncerTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "io.chouti.LeadingDebouncerTests")

  func test_invalid_interval() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "The interval should be greater than 0."
    }

    let debouncer = LeadingDebouncer(interval: -1)

    // debouncer has 0 interval, so it should always trigger
    expect(debouncer.debounce()) == true
    expect(debouncer.debounce()) == true
    expect(debouncer.debounce()) == true

    var called = false
    debouncer.debounce {
      called = true
    }
    expect(called) == true

    called = false
    debouncer.debounce {
      called = true
    }
    expect(called) == true

    Assert.resetTestAssertionFailureHandler()
  }

  func test() {
    let expectation = expectation(description: "wait")

    let debouncer = LeadingDebouncer(interval: 0.1)
    let debouncer2 = LeadingDebouncer(interval: 0.1)

    var receivedValues: [Float] = []

    delay(0.05, leeway: .zero, queue: queue) {
      // first should pass
      debouncer.debounce {
        receivedValues.append(1)
      }
      expect(receivedValues) == [1]
      expect(debouncer2.debounce()) == true
    }

    delay(0.1, leeway: .zero, queue: queue) {
      // should ignore
      debouncer.debounce {
        receivedValues.append(2)
      }
      expect(receivedValues) == [1]
      expect(debouncer2.debounce()) == false
    }

    delay(0.15, leeway: .zero, queue: queue) {
      // should ignore, only 0.15 passed
      debouncer.debounce {
        receivedValues.append(3)
      }
      expect(receivedValues) == [1]
      expect(debouncer2.debounce()) == false
    }

    delay(0.3, leeway: .zero, queue: queue) {
      // should pass, 0.2s passed
      debouncer.debounce {
        receivedValues.append(4)
      }
      expect(receivedValues) == [1, 4]
      expect(debouncer2.debounce()) == true
    }

    delay(0.45, leeway: .zero, queue: queue) {
      // should pass, 0.025s passed
      debouncer.debounce {
        receivedValues.append(5)
      }
      expect(receivedValues) == [1, 4, 5]
      expect(debouncer2.debounce()) == true

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }
}

class TrailingDebouncerTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "io.chouti.TrailingDebouncerTests")

  func test_invalid_interval() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "The interval should be greater than 0."
    }

    let debouncer = TrailingDebouncer(interval: -1, queue: queue)

    var called = false
    debouncer.debounce {
      called = true
    }
    expect(called) == true

    called = false
    debouncer.debounce {
      called = true
    }
    expect(called) == true

    called = false
    debouncer.debounce {
      called = true
    }
    expect(called) == true

    Assert.resetTestAssertionFailureHandler()
  }

  func test() {
    let expectation = expectation(description: "wait")

    let debouncer = TrailingDebouncer(interval: 0.05, queue: queue)

    var receivedValues: [Float] = []

    delay(0.025, leeway: .zero, queue: queue) {
      let isDebounced = debouncer.debounce {
        receivedValues.append(0.01)
      }
      expect(isDebounced) == false
    }

    delay(0.05, leeway: .zero, queue: queue) {
      let isDebounced = debouncer.debounce {
        receivedValues.append(0.02)
      }
      expect(isDebounced) == true
    }

    delay(0.075, leeway: .zero, queue: queue) {
      let isDebounced = debouncer.debounce {
        receivedValues.append(0.03)
      }
      expect(isDebounced) == true
    }

    delay(0.1225, leeway: .zero, queue: queue) {
      // should no value
      expect(receivedValues).to(beEmpty())
    }

    delay(0.1375, leeway: .zero, queue: queue) {
      // should have callback
      expect(receivedValues) == [0.03]

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }
}
