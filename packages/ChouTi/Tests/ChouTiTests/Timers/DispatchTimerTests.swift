//
//  DispatchTimerTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class DispatchTimerTests: XCTestCase {

  func testFireImmediately() {
    var fireCount = 0
    let queue = DispatchQueue.makeSerialQueue(label: "test", qos: .userInteractive)
    let timer = DispatchTimer(queue: queue) {
      expect(DispatchQueue.isOnQueue(queue)) == true
      fireCount += 1
    }
    timer.fire(every: .seconds(1), leeway: .zero, fireImmediately: true)

    wait(timeout: 0.1)
    expect(fireCount) == 1

    expect(fireCount).toEventually(beEqual(to: 2))
  }
}
