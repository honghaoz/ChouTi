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

@testable import ChouTi

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
    let clock = MockClock()
    let debouncer = LeadingDebouncer(interval: 0.1)
    debouncer.test.clock = clock
    _ = debouncer.test.clock

    let debouncer2 = LeadingDebouncer(interval: 0.1)
    debouncer2.test.clock = clock
    _ = debouncer2.test.clock

    var receivedValues: [Float] = []

    clock.advance(to: 0.05)

    // first should pass
    debouncer.debounce {
      receivedValues.append(1)
    }
    expect(receivedValues) == [1]
    expect(debouncer2.debounce()) == true

    clock.advance(to: 0.1)
    // should ignore
    debouncer.debounce {
      receivedValues.append(2)
    }
    expect(receivedValues) == [1]
    expect(debouncer2.debounce()) == false

    clock.advance(to: 0.15)
    // should ignore, only 0.15 passed
    debouncer.debounce {
      receivedValues.append(3)
    }
    expect(receivedValues) == [1]
    expect(debouncer2.debounce()) == false

    clock.advance(to: 0.3)
    // should pass, 0.2s passed
    debouncer.debounce {
      receivedValues.append(4)
    }
    expect(receivedValues) == [1, 4]
    expect(debouncer2.debounce()) == true

    clock.advance(to: 0.45)
    // should pass, 0.025s passed
    debouncer.debounce {
      receivedValues.append(5)
    }
    expect(receivedValues) == [1, 4, 5]
    expect(debouncer2.debounce()) == true
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
    let debouncer = TrailingDebouncer(interval: 0.05)
    let clock = MockClock()
    debouncer.test.clock = clock
    _ = debouncer.test.clock

    var receivedValues: [Float] = []

    clock.advance(to: 0.025)
    do {
      let isDebounced = debouncer.debounce {
        receivedValues.append(0.01)
      }
      expect(isDebounced) == false
    }

    clock.advance(to: 0.05)
    do {
      let isDebounced = debouncer.debounce {
        receivedValues.append(0.02)
      }
      expect(isDebounced) == true
    }

    clock.advance(to: 0.075)
    do {
      let isDebounced = debouncer.debounce {
        receivedValues.append(0.03)
      }
      expect(isDebounced) == true
    }

    clock.advance(to: 0.1225)
    // should no value
    expect(receivedValues).to(beEmpty())

    clock.advance(to: 0.1375)
    // should have callback
    expect(receivedValues) == [0.03]
  }
}
