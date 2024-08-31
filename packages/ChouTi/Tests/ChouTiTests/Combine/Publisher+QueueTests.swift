//
//  Publisher+QueueTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/21/23.
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

import Combine

import ChouTiTest

import ChouTi

class Publisher_QueueTests: XCTestCase {

  var cancellableSet: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellableSet = []
  }

  override func tearDown() {
    cancellableSet = nil
    super.tearDown()
  }

  func testReceiveOnQueue() {
    let expectation = XCTestExpectation(description: "Receive on specified queue")
    let queue = DispatchQueue(label: "test.queue")

    Just(1)
      .receive(on: queue)
      .sink { _ in
        expect(DispatchQueue.currentQueueLabel) == "test.queue"
        expectation.fulfill()
      }
      .store(in: &cancellableSet)

    wait(for: [expectation], timeout: 1.0)
  }

  func testReceiveOnQueueWithQOS() {
    let expectation = XCTestExpectation(description: "Receive on specified queue with QOS")
    let queue = DispatchQueue(label: "test.queue.with.qos", qos: .userInteractive)

    Just(1)
      .receive(on: queue, qos: .userInteractive)
      .sink { _ in
        expect(DispatchQueue.currentQueueLabel) == "test.queue.with.qos"
        expectation.fulfill()
      }
      .store(in: &cancellableSet)

    wait(for: [expectation], timeout: 1.0)
  }

  func testReceiveOnQueueAlwaysAsync_true() {
    let expectation = XCTestExpectation(description: "Receive on specified queue always asynchronously")
    var receivedValue: Int?
    Just(1)
      .receive(on: .main, alwaysAsync: true)
      .sink { value in
        receivedValue = value
        expectation.fulfill()
      }
      .store(in: &cancellableSet)

    expect(receivedValue) == nil
    wait(for: [expectation], timeout: 1.0)
  }

  func testReceiveOnQueueAlwaysAsync_false() {
    var receivedValue: Int?
    Just(1)
      .receive(on: .main, alwaysAsync: false)
      .sink { value in
        receivedValue = value
      }
      .store(in: &cancellableSet)

    expect(receivedValue) == 1
  }
}
