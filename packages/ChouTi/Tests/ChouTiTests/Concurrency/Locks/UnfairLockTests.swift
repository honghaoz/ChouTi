//
//  UnfairLockTests.swift
//
//  Created by Honghao Zhang on 5/6/23.
//  Copyright © 2024 ChouTi. All rights reserved.
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
