//
//  DispatchTimerTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
import ChouTi

class DispatchTimerTests: XCTestCase {

  func testFireImmediately() {
    var fireCount = 0
    let queue = DispatchQueue.makeSerialQueue(label: "test", qos: .userInteractive)
    let timer = DispatchTimer(queue: queue) {
      XCTAssertTrue(DispatchQueue.isOnQueue(queue))
      fireCount += 1
    }
    timer.fire(every: .seconds(1), leeway: .zero, fireImmediately: true)

    wait(timeout: 0.1)
    XCTAssertEqual(fireCount, 1)

    // TODO: restore tests
    // XCTAssertEqualEventually(fireCount, 2)
  }
}
