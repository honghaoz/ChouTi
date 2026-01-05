//
//  ThrottlerTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/24/23.
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

class ThrottlerTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "io.chouti.ThrottlerTests")

  private var clock: MockClock!

  override func setUp() {
    clock = MockClock()
    ClockProvider.current = clock
  }

  override func tearDown() {
    ClockProvider.reset()
  }

  func test_invalidInterval() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "The interval should be greater than 0."
    }

    let throttler = Throttler(interval: -1, latest: true, queue: queue)

    var called = false
    throttler.throttle {
      called = true
    }
    expect(called) == true

    called = false
    throttler.throttle {
      called = true
    }
    expect(called) == true

    called = false
    throttler.throttle {
      called = true
    }
    expect(called) == true

    Assert.resetTestAssertionFailureHandler()
  }

  func test_latest() {
    let throttler = Throttler(interval: 1, latest: true, queue: .main)

    var receivedValues: [Float] = []

    throttler.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [] // throttled

    throttler.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [] // throttled

    clock.advance(to: 1.1)

    expect(receivedValues) == [2] // the latest value is appended

    throttler.throttle {
      receivedValues.append(3) // throttled
    }
    expect(receivedValues) == [2]

    throttler.throttle {
      receivedValues.append(4) // throttled
    }
    expect(receivedValues) == [2]

    clock.advance(to: 2.5)

    expect(receivedValues) == [2, 4] // the latest value is appended
  }

  func test_latest_invokeImmediately() {
    let throttler = Throttler(interval: 0.1, latest: true, invokeImmediately: true, queue: .main)

    var receivedValues: [Float] = []

    throttler.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [1] // the value is appended immediately because this is the first value

    throttler.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [1] // throttled

    throttler.throttle {
      receivedValues.append(3)
    }
    expect(receivedValues) == [1] // throttled

    clock.advance(to: 0.1)

    expect(receivedValues) == [1, 3] // the latest value is appended

    throttler.throttle {
      receivedValues.append(4) // throttled
    }
    expect(receivedValues) == [1, 3]

    throttler.throttle {
      receivedValues.append(5) // throttled
    }
    expect(receivedValues) == [1, 3]

    clock.advance(to: 0.2)
    expect(receivedValues) == [1, 3, 5] // the latest value is appended

    clock.advance(to: 0.4) // long time after the last value
    throttler.throttle {
      receivedValues.append(6)
    }
    expect(receivedValues) == [1, 3, 5, 6] // the value is appended immediately
  }

  func test_first() {
    let throttler = Throttler(interval: 0.1, latest: false, queue: .main)

    var receivedValues: [Float] = []

    throttler.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [] // throttled

    throttler.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [] // throttled

    clock.advance(to: 0.15)

    expect(receivedValues) == [1] // first appended value (non-latest)

    throttler.throttle {
      receivedValues.append(3)
    }
    expect(receivedValues) == [1] // throttled

    throttler.throttle {
      receivedValues.append(4)
    }
    expect(receivedValues) == [1] // throttled

    clock.advance(to: 0.3)
    expect(receivedValues) == [1, 3] // first appended value (non-latest)
  }

  func test_self_deallocated() {
    var throttler: Throttler? = Throttler(interval: 0.1, latest: true, queue: queue)

    var called = false
    throttler?.throttle {
      called = true
    }

    throttler = nil

    wait(timeout: 0.2)

    expect(called) == false
  }

  func test_self_deallocated_withMockClock() {
    var throttler: Throttler? = Throttler(interval: 0.1, latest: true, queue: .main)

    var called = false
    throttler?.throttle {
      called = true
    }
    expect(called) == false

    // deallocate the throttler before the delay task fires
    throttler = nil

    // advance time to when the delay task should fire
    clock.advance(to: 0.15)

    // the block should not be called because throttler was deallocated
    expect(called) == false
  }

  func test_self_deallocated_invokeImmediately() {
    var throttler: Throttler? = Throttler(interval: 0.1, latest: true, invokeImmediately: true, queue: .main)

    var receivedValues: [Int] = []

    // first call - invokes immediately
    throttler?.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [1]

    // second call - throttled
    throttler?.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [1]

    // deallocate the throttler before the delay task fires
    throttler = nil

    // advance time to when the delay task should fire
    clock.advance(to: 0.15)

    // the second block should not be called because throttler was deallocated
    expect(receivedValues) == [1]
  }
}
