//
//  Memory+MemoryWarningPublishingTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/26/24.
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

#if os(macOS)

import Combine

import ChouTiTest

@testable import ChouTi

class Memory_MemoryWarningPublisherTests: XCTestCase {

  func test_memoryWarningPublisher() {
    let expectation = XCTestExpectation(description: "memoryWarningPublisher")
    let memoryWarningObservationToken = Memory.memoryWarningPublisher
      .sink {
        expectation.fulfill()
      }
    _ = memoryWarningObservationToken

    Memory.test.monitor?.test.simulateMemoryPressureEvent(.warning)

    wait(for: [expectation], timeout: 1)
  }

  func test_memoryWarningPublisher_multipleSubscribers() {
    let expectation1 = XCTestExpectation(description: "subscriber1")
    let expectation2 = XCTestExpectation(description: "subscriber2")

    let token1 = Memory.memoryWarningPublisher
      .sink {
        expectation1.fulfill()
      }

    let token2 = Memory.memoryWarningPublisher
      .sink {
        expectation2.fulfill()
      }

    _ = token1
    _ = token2

    Memory.test.monitor?.test.simulateMemoryPressureEvent(.warning)

    wait(for: [expectation1, expectation2], timeout: 1)
  }

  func test_memoryWarningPublisher_sameInstanceOnMultipleAccesses() {
    // when accessing the publisher multiple times
    let publisher1 = Memory.memoryWarningPublisher
    let publisher2 = Memory.memoryWarningPublisher

    // then they should share the same underlying PassthroughSubject
    // extract the underlying publisher's memory address by diving into the AnyPublisher structure
    func getUnderlyingPublisherAddress(_ publisher: AnyPublisher<some Any, Never>) -> String? {
      let mirror = Mirror(reflecting: publisher)

      // AnyPublisher has a "box" property that wraps the underlying publisher
      guard let boxChild = mirror.children.first,
            boxChild.label == "box"
      else {
        return nil
      }

      // mirror the box to get to the actual publisher inside
      let boxMirror = Mirror(reflecting: boxChild.value)

      // look for the underlying publisher
      for child in boxMirror.children {
        if child.label == "base" {
          // found the underlying publisher - get its memory address
          return String(describing: Unmanaged.passUnretained(child.value as AnyObject).toOpaque())
        }
      }

      // if not found, return nil
      return nil
    }

    let address1 = getUnderlyingPublisherAddress(publisher1)
    let address2 = getUnderlyingPublisherAddress(publisher2)

    expect(address1).toNot(beNil())
    expect(address2).toNot(beNil())

    // both publishers should point to the same underlying PassthroughSubject
    expect(address1) == address2
  }

  func test_memoryWarningPublisher_cancellation() {
    let expectation = XCTestExpectation(description: "memoryWarning")
    expectation.expectedFulfillmentCount = 1
    expectation.assertForOverFulfill = true

    var token: AnyCancellable? = Memory.memoryWarningPublisher
      .sink {
        expectation.fulfill()
      }

    Memory.test.monitor?.test.simulateMemoryPressureEvent(.warning)

    // cancel the subscription
    token?.cancel()
    token = nil

    // trigger again - should not fulfill a second time
    Memory.test.monitor?.test.simulateMemoryPressureEvent(.warning)

    wait(for: [expectation], timeout: 1)
  }

  func test_MemoryPressureMonitor() {
    // given a memory pressure monitor
    var callCount = 0
    let monitor = MemoryPressureMonitor(warningHandler: {
      callCount += 1
    })

    // when simulating a memory pressure event
    monitor.test.simulateMemoryPressureEvent(.warning)
    expect(callCount) == 1

    monitor.test.simulateMemoryPressureEvent(.critical)
    expect(callCount) == 2

    monitor.test.simulateMemoryPressureEvent(.warning)
    expect(callCount) == 3

    monitor.test.simulateMemoryPressureEvent(.critical)
    expect(callCount) == 4

    // when simulating a normal event
    monitor.test.simulateMemoryPressureEvent(.normal)
    expect(callCount) == 4 // no change
  }
}

#endif
