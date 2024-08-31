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

import ChouTi

class ThrottlerTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "io.chouti.ThrottlerTests")

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
    let expectation = expectation(description: "wait")

    let throttler = Throttler(interval: 0.05, latest: true, queue: queue)

    var receivedValues: [Float] = []

    throttler.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [] // throttled

    throttler.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [] // throttled

    delay(0.075, leeway: .zero) {
      expect(receivedValues) == [2] // last appended value (latest)

      throttler.throttle {
        receivedValues.append(3) // throttled
      }
      expect(receivedValues) == [2]

      throttler.throttle {
        receivedValues.append(4) // throttled
      }
      expect(receivedValues) == [2]
    }

    delay(0.2, leeway: .zero) {
      expect(receivedValues) == [2, 4] // last appended value (latest)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_first() {
    let expectation = expectation(description: "wait")

    let throttler = Throttler(interval: 0.1, latest: false, queue: queue)

    var receivedValues: [Float] = []

    throttler.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [] // throttled

    throttler.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [] // throttled

    delay(0.15, leeway: .zero) {
      expect(receivedValues) == [1] // first appended value (non-latest)

      throttler.throttle {
        receivedValues.append(3)
      }
      expect(receivedValues) == [1] // throttled

      throttler.throttle {
        receivedValues.append(4)
      }
      expect(receivedValues) == [1] // throttled
    }

    delay(0.3, leeway: .zero) {
      expect(receivedValues) == [1, 3] // first appended value (non-latest)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_latest_invokeImmediately() {
    let expectation = expectation(description: "wait")

    let throttler = Throttler(interval: 0.1, latest: true, invokeImmediately: true, queue: queue)

    var receivedValues: [Float] = []

    throttler.throttle {
      receivedValues.append(1)
    }
    expect(receivedValues) == [1] // invoked immediately

    throttler.throttle {
      receivedValues.append(2)
    }
    expect(receivedValues) == [1] // throttled

    delay(0.15, leeway: .zero) {
      expect(receivedValues) == [1, 2] // last appended value (latest)

      throttler.throttle {
        receivedValues.append(3) // throttled
      }
      expect(receivedValues) == [1, 2]

      throttler.throttle {
        receivedValues.append(4) // throttled
      }
      expect(receivedValues) == [1, 2]
    }

    delay(0.3, leeway: .zero) {
      expect(receivedValues) == [1, 2, 4] // last appended value (latest)
    }

    delay(0.4, leeway: .zero) {
      expect(receivedValues) == [1, 2, 4]
      throttler.throttle {
        receivedValues.append(5)
      }
      expect(receivedValues) == [1, 2, 4, 5] // invoked immediately

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
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
}
