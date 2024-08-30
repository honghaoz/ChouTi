//
//  DispatchWorkItem+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 7/24/21.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

class DispatchWorkItem_ExtensionsTests: XCTestCase {

  private var backgroundQueue: DispatchQueue!

  override func setUp() {
    backgroundQueue = .make(label: "test-queue")
  }

  func test_zeroDelay() {
    let expectation = XCTestExpectation(description: "should run")

    DispatchWorkItem {
      expect(DispatchQueue.isOnQueue(.main)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: .main, delay: 0)

    wait(for: [expectation], timeout: 0.001)
  }

  func test_negativeDelay() {
    let expectation = XCTestExpectation(description: "should run")

    DispatchWorkItem {
      expect(DispatchQueue.isOnQueue(.main)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: .main, delay: -5)

    wait(for: [expectation], timeout: 0.001)
  }

  func test_positiveDelay() {
    let expectation = XCTestExpectation(description: "should run")

    var isCalled = false
    DispatchWorkItem {
      isCalled = true
      expect(DispatchQueue.isOnQueue(.main)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: .main, delay: 0.1)

    wait(timeout: 0.01)
    expect(isCalled) == false

    wait(for: [expectation], timeout: 1)
  }

  func testPositiveDelayAndCancel() {
    let expectation = XCTestExpectation(description: "should not run")
    expectation.isInverted = true

    var isCalled = false
    let task = DispatchWorkItem { [weak self] in
      isCalled = true
      guard let self else {
        fail("no self")
        return
      }
      expect(DispatchQueue.isOnQueue(self.backgroundQueue)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0.2)

    wait(timeout: 0.02)
    expect(isCalled) == false

    task.cancel()

    wait(for: [expectation], timeout: 0.3)
  }
}
