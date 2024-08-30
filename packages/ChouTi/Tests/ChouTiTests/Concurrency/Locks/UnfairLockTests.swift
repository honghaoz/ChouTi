//
//  UnfairLockTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/6/23.
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

final class UnfairLockTests: XCTestCase {

  func testLockUnlock() {
    let lock = UnfairLock()
    lock.lock()
    expect(lock.tryLock()) == false
    lock.unlock()
  }

  func testTryLock() {
    let lock = UnfairLock()
    expect(lock.tryLock()) == true
    lock.unlock()
    expect(lock.tryLock()) == true
    expect(lock.tryLock()) == false
    lock.unlock()
  }

  func testWithLock() {
    let lock = UnfairLock()
    let result = lock.withLock { () -> String in
      "Hello, World!"
    }
    expect(result) == "Hello, World!"
  }

  func testLockConcurrency() {
    let lock = UnfairLock()
    let expectation = XCTestExpectation(description: "Waiting for concurrent access")
    let dispatchQueue = DispatchQueue(label: "testLockConcurrency", attributes: .concurrent)
    var counter = 0

    for _ in 0 ..< 10000 {
      dispatchQueue.async {
        lock.withLock {
          counter += 1
        }
        if counter == 10000 {
          expectation.fulfill()
        }
      }
    }

    wait(for: [expectation], timeout: 10.0)
    expect(counter) == 10000
  }

  func testLockConcurrency2() {
    let lock = UnfairLock()
    var counter = 0

    let iterations = 10000
    DispatchQueue.concurrentPerform(iterations: iterations) { _ in
      lock.withLock {
        counter += 1
      }
    }

    expect(counter) == iterations
  }

  func testLockPerformance() {
    let lock = UnfairLock()
    var counter = 0

    measure {
      let iterations = 100000
      DispatchQueue.concurrentPerform(iterations: iterations) { _ in
        lock.withLock {
          counter += 1
        }
      }
      expect(counter) == iterations
      counter = 0
    }
  }
}
