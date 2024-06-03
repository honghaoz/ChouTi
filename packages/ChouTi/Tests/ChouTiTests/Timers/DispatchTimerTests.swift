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

  func test_repeatTimer_fireImmediately() {
    var fireCount = 0
    let queue = DispatchQueue.makeSerialQueue(label: "test", qos: .userInteractive)
    let timer = DispatchTimer(queue: queue) {
      expect(DispatchQueue.isOnQueue(queue)) == true
      fireCount += 1
    }
    timer.fire(every: .seconds(0.2), leeway: .zero, fireImmediately: true)

    delay(0.1, leeway: .zero) {
      expect(fireCount) == 1
    }

    expect(fireCount).toEventually(beEqual(to: 2))
  }

  func test_repeatingTimer_fireImmediately() {
    do {
      var fireCount = 0
      let queue = DispatchQueue.makeSerialQueue(label: "test", qos: .userInteractive)
      let timer = DispatchTimer.repeatingTimer(every: 0.2, isStrict: true, leeway: .zero, fireImmediately: true, queue: queue) {
        expect(DispatchQueue.isOnQueue(queue)) == true
        fireCount += 1
      }
      _ = timer

      delay(0.1, leeway: .zero) {
        expect(fireCount) == 1
      }

      expect(fireCount).toEventually(beEqual(to: 2))
    }

    // duration
    do {
      var fireCount = 0
      let queue = DispatchQueue.makeSerialQueue(label: "test", qos: .userInteractive)
      let timer = DispatchTimer.repeatingTimer(every: .seconds(0.2), isStrict: true, leeway: .zero, fireImmediately: true, queue: queue) {
        expect(DispatchQueue.isOnQueue(queue)) == true
        fireCount += 1
      }
      _ = timer

      delay(0.1, leeway: .zero) {
        expect(fireCount) == 1
      }

      expect(fireCount).toEventually(beEqual(to: 2))
    }
  }
}
