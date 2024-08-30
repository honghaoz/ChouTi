//
//  DispatchQueue+SharedSerialQueuesTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 6/1/24.
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

final class DispatchQueue_SharedSerialQueuesTests: XCTestCase {

  func test_shared() {
    let userInteractiveQueue = DispatchQueue.shared(qos: .userInteractive)
    expect(userInteractiveQueue.label) == "io.chouti.queue.qos-ui"
    expect(userInteractiveQueue.qos) == .userInteractive

    let userInitiatedQueue = DispatchQueue.shared(qos: .userInitiated)
    expect(userInitiatedQueue.label) == "io.chouti.queue.qos-user-initiated"
    expect(userInitiatedQueue.qos) == .userInitiated

    let defaultQueue = DispatchQueue.shared(qos: .default)
    expect(defaultQueue.label) == "io.chouti.queue.qos-default"
    expect(defaultQueue.qos) == .default

    let utilityQueue = DispatchQueue.shared(qos: .utility)
    expect(utilityQueue.label) == "io.chouti.queue.qos-utility"
    expect(utilityQueue.qos) == .utility

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "qos .background is not recommended, use .utility instead."
    }
    let backgroundQueue = DispatchQueue.shared(qos: .background)
    expect(backgroundQueue.label) == "io.chouti.queue.qos-background"
    expect(backgroundQueue.qos) == .background
    Assert.resetTestAssertionFailureHandler()

    let unspecifiedQueue = DispatchQueue.shared(qos: .unspecified)
    expect(unspecifiedQueue.label) == "io.chouti.queue.qos-default"
    expect(unspecifiedQueue.qos) == .default

    let customQueue = DispatchQueue.shared(qos: DispatchQoS(qosClass: .default, relativePriority: 10))
    expect(customQueue.label) == "io.chouti.queue.qos-default"
    expect(customQueue.qos) == .default
  }
}
