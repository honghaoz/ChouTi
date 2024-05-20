//
//  UnfairLockTests.swift
//
//  Created by Honghao Zhang on 5/6/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
@testable import ChouTi

final class UnfairLockTests: XCTestCase {

  func testLockUnlock() {
    let lock = UnfairLock()
    lock.lock()
    XCTAssertFalse(lock.tryLock())
    lock.unlock()
  }

  func testTryLock() {
    let lock = UnfairLock()
    XCTAssertTrue(lock.tryLock())
    lock.unlock()
    XCTAssertTrue(lock.tryLock())
    XCTAssertFalse(lock.tryLock())
    lock.unlock()
  }

  func testWithLock() {
    let lock = UnfairLock()
    let result = lock.withLock { () -> String in
      "Hello, World!"
    }
    XCTAssertEqual(result, "Hello, World!")
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
    XCTAssertEqual(counter, 10000)
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

    XCTAssertEqual(counter, iterations)
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
      XCTAssertEqual(counter, iterations)
      counter = 0
    }
  }
}
