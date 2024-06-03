//
//  DispatchWorkItem+DelayTests.swift
//
//  Created by Honghao Zhang on 6/2/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class DispatchWorkItem_Delay: XCTestCase {

  func testDelayWithTimeInterval() {
    let expectation = self.expectation(description: "should execute")

    DispatchWorkItem.delay(0.1, queue: .main) {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 0.2)
  }

  func testDelayWithDuration() {
    let expectation = self.expectation(description: "should execute")

    let delay: Duration = .milliseconds(100)

    DispatchWorkItem.delay(delay, queue: .main) {
      expectation.fulfill()
    }

    waitForExpectations(timeout: 0.2)
  }
}
