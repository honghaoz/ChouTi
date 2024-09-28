//
//  SystemClockTests.swift
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

import ChouTi

class SystemClockTests: XCTestCase {

  func testNow() {
    let clock = SystemClock()
    expect(clock.now()).to(beApproximatelyEqual(to: Date().timeIntervalSince1970, within: 1e-4))
  }

  func test_delay_executed() {
    let expectation = self.expectation(description: "delay")

    let clock = SystemClock()
    _ = clock.delay(0.1, queue: .main) {
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 0.15)
  }

  func test_delay_cancelled() {
    let expectation = self.expectation(description: "delay")
    expectation.isInverted = true

    let clock = SystemClock()
    let token = clock.delay(0.1, queue: .main) {
      expectation.fulfill()
    }
    token.cancel()

    wait(for: [expectation], timeout: 0.15)
  }
}
