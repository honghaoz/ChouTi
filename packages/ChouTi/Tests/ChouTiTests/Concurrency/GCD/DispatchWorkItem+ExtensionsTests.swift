//
//  DispatchWorkItem+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 7/24/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
import ChouTi

class DispatchWorkItem_ExtensionsTests: XCTestCase {

  var backgroundQueue: DispatchQueue!

  override func setUp() {
    backgroundQueue = .shared(qos: .userInteractive)
  }

  func testZeroDelay() {
    let expectation = XCTestExpectation(description: "should run")

    DispatchWorkItem { [weak self] in
      guard let self else {
        XCTFail("no self")
        return
      }
      XCTAssert(DispatchQueue.isOnQueue(self.backgroundQueue))
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0)

    wait(for: [expectation], timeout: 0.2)
  }

  func testNegativeDelay() {
    let expectation = XCTestExpectation(description: "should run")

    DispatchWorkItem { [weak self] in
      guard let self else {
        XCTFail("no self")
        return
      }
      XCTAssert(DispatchQueue.isOnQueue(self.backgroundQueue))
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: -5)

    wait(for: [expectation], timeout: 0.001)
  }

  func testPositiveDelay() {
    let expectation = XCTestExpectation(description: "should run")

    var isCalled = false
    DispatchWorkItem { [weak self] in
      isCalled = true
      guard let self else {
        XCTFail("no self")
        return
      }
      XCTAssert(DispatchQueue.isOnQueue(self.backgroundQueue))
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0.2)

    wait(timeout: 0.02)
    XCTAssertFalse(isCalled)
    wait(for: [expectation], timeout: 1)
  }

  func testPositiveDelayAndCancel() {
    let expectation = XCTestExpectation(description: "should not run")
    expectation.isInverted = true

    var isCalled = false
    let task = DispatchWorkItem { [weak self] in
      isCalled = true
      guard let self else {
        XCTFail("no self")
        return
      }
      XCTAssert(DispatchQueue.isOnQueue(self.backgroundQueue))
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0.2)

    wait(timeout: 0.02)
    XCTAssertFalse(isCalled)
    task.cancel()

    wait(for: [expectation], timeout: 1)
  }
}
