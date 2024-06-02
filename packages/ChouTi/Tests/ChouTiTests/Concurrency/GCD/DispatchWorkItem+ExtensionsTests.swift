//
//  DispatchWorkItem+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 7/24/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class DispatchWorkItem_ExtensionsTests: XCTestCase {

  private var backgroundQueue: DispatchQueue!

  override func setUp() {
    backgroundQueue = .shared(qos: .userInteractive)
  }

  func test_zeroDelay() {
    let expectation = XCTestExpectation(description: "should run")

    DispatchWorkItem { [weak self] in
      guard let self else {
        XCTFail("no self")
        return
      }
      expect(DispatchQueue.isOnQueue(self.backgroundQueue)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0)

    wait(for: [expectation], timeout: 0.001)
  }

  func test_negativeDelay() {
    let expectation = XCTestExpectation(description: "should run")

    DispatchWorkItem { [weak self] in
      guard let self else {
        XCTFail("no self")
        return
      }
      expect(DispatchQueue.isOnQueue(self.backgroundQueue)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: -5)

    wait(for: [expectation], timeout: 0.001)
  }

  func test_positiveDelay() {
    let expectation = XCTestExpectation(description: "should run")

    var isCalled = false
    DispatchWorkItem { [weak self] in
      isCalled = true
      guard let self else {
        XCTFail("no self")
        return
      }
      expect(DispatchQueue.isOnQueue(self.backgroundQueue)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0.2)

    wait(timeout: 0.02)
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
        XCTFail("no self")
        return
      }
      expect(DispatchQueue.isOnQueue(self.backgroundQueue)) == true
      expectation.fulfill()
    }
    .asyncDispatch(to: backgroundQueue, delay: 0.2)

    wait(timeout: 0.02)
    expect(isCalled) == false

    task.cancel()

    wait(for: [expectation], timeout: 1)
  }
}
