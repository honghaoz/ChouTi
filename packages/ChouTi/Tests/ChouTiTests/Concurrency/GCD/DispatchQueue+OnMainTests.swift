//
//  DispatchQueue+OnMainTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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

final class DispatchQueue_OnMainAsyncTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "test-queue")

  func test_onMainAsync_fromMain() {
    do {
      var isExecuted = false
      DispatchQueue.onMainAsync {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      onMainAsync {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    // workItem
    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      DispatchQueue.onMainAsync(execute: workItem)
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      onMainAsync(execute: workItem)
      expect(isExecuted) == true
    }
  }

  func test_onMainAsync_fromMain_positiveDelay() {
    do {
      var isExecuted = false
      // if delay is 0, it dispatches to next run loop
      DispatchQueue.onMainAsync(delay: 0.01) {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == false
      expect(isExecuted).toEventually(beTrue())
    }

    do {
      var isExecuted = false
      // if delay is 0, it dispatches to next run loop
      onMainAsync(delay: 0.01) {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == false
      expect(isExecuted).toEventually(beTrue())
    }

    // workItem
    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      DispatchQueue.onMainAsync(delay: 0.01, execute: workItem)
      expect(isExecuted) == false
      expect(isExecuted).toEventually(beTrue())
    }

    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      onMainAsync(delay: 0.01, execute: workItem)
      expect(isExecuted) == false
      expect(isExecuted).toEventually(beTrue())
    }
  }

  func test_onMainAsync_fromMain_zeroDelay() {
    do {
      var isExecuted = false
      // delay is zero, dispatches directly
      DispatchQueue.onMainAsync(delay: 0) {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      // delay is zero, dispatches directly
      onMainAsync(delay: 0) {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    // workItem
    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      DispatchQueue.onMainAsync(delay: 0, execute: workItem)
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      onMainAsync(delay: 0, execute: workItem)
      expect(isExecuted) == true
    }
  }

  func test_onMainAsync_fromMain_negativeDelay() {
    do {
      var isExecuted = false
      // delay is negative, dispatches directly
      DispatchQueue.onMainAsync(delay: -1) {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      // delay is negative, dispatches directly
      onMainAsync(delay: -1) {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    // workItem
    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      DispatchQueue.onMainAsync(delay: -1, execute: workItem)
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      let workItem = DispatchWorkItem {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      onMainAsync(delay: -1, execute: workItem)
      expect(isExecuted) == true
    }
  }

  func test_onMainAsync_fromBackground() {
    do {
      var isExecuted = false
      queue.async {
        expect(Thread.isMainThread) == false
        DispatchQueue.onMainAsync {
          expect(Thread.isMainThread) == true
          isExecuted = true
        }
        expect(isExecuted) == false
      }
      expect(isExecuted).toEventually(beTrue())
    }

    do {
      var isExecuted = false
      queue.async {
        expect(Thread.isMainThread) == false
        onMainAsync {
          expect(Thread.isMainThread) == true
          isExecuted = true
        }
        expect(isExecuted) == false
      }
      expect(isExecuted).toEventually(beTrue())
    }

    // workItem
    do {
      var isExecuted = false
      queue.async {
        expect(Thread.isMainThread) == false
        let workItem = DispatchWorkItem {
          expect(Thread.isMainThread) == true
          isExecuted = true
        }
        DispatchQueue.onMainAsync(execute: workItem)
        expect(isExecuted) == false
      }
      expect(isExecuted).toEventually(beTrue())
    }

    do {
      var isExecuted = false
      queue.async {
        expect(Thread.isMainThread) == false
        let workItem = DispatchWorkItem {
          expect(Thread.isMainThread) == true
          isExecuted = true
        }
        onMainAsync(execute: workItem)
        expect(isExecuted) == false
      }
      expect(isExecuted).toEventually(beTrue())
    }
  }

  func test_onMainAsync_fromBackground_positiveDelay() {
    do {
      var isExecuted = false
      queue.async {
        expect(Thread.isMainThread) == false
        DispatchQueue.onMainAsync(delay: 0.01) {
          expect(Thread.isMainThread) == true
          isExecuted = true
        }
        expect(isExecuted) == false
      }
      expect(isExecuted).toEventually(beTrue())
    }

    do {
      var isExecuted = false
      queue.async {
        expect(Thread.isMainThread) == false
        onMainAsync(delay: 0.01) {
          expect(Thread.isMainThread) == true
          isExecuted = true
        }
        expect(isExecuted) == false
      }
      expect(isExecuted).toEventually(beTrue())
    }
  }

  // MARK: - onMainSync

  func test_onMainSync_fromMain() {
    do {
      var isExecuted = false
      DispatchQueue.onMainSync {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }

    do {
      var isExecuted = false
      onMainSync {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }
      expect(isExecuted) == true
    }
  }

  func test_onMainSync_fromBackground() {
    var isExecuted = false

    queue.async {
      expect(Thread.isMainThread) == false

      DispatchQueue.onMainSync {
        expect(Thread.isMainThread) == true
        isExecuted = true
      }

      expect(isExecuted) == true
    }

    expect(isExecuted).toEventually(beTrue())
  }
}
