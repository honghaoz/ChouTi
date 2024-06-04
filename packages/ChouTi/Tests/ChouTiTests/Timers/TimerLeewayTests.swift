//
//  TimerLeewayTests.swift
//
//  Created by Honghao Zhang on 11/13/22.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class TimerLeewayTests: XCTestCase {

  func test_isStrict() {
    do {
      let leeway = TimerLeeway.zero
      expect(leeway.isStrict) == true
    }

    do {
      let leeway = TimerLeeway.seconds(0)
      expect(leeway.isStrict) == true
    }

    do {
      let leeway = TimerLeeway.fractional(0)
      expect(leeway.isStrict) == true
    }

    do {
      let leeway = TimerLeeway.fractional(0.23)
      expect(leeway.isStrict) == false
    }
  }

  func test_leewayInterval() {
    do {
      let leeway = TimerLeeway.zero
      expect(leeway.leewayInterval(from: 200)) == 0
    }

    do {
      let leeway = TimerLeeway.seconds(98)
      expect(leeway.leewayInterval(from: 200)) == 98
    }

    do {
      let leeway = TimerLeeway.fractional(0.23)
      expect(leeway.leewayInterval(from: 200)) == 46
    }

    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "leeway should be less than or equal to the firing interval."
      }
      let leeway = TimerLeeway.seconds(201)
      expect(leeway.leewayInterval(from: 200)) == 201
      Assert.resetTestAssertionFailureHandler()
    }

    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "leeway percentage should be less than or equal to 1."
      }
      let leeway = TimerLeeway.fractional(1.1)
      expect(leeway.leewayInterval(from: 200)).to(beApproximatelyEqual(to: 220, within: 1e-9))
      Assert.resetTestAssertionFailureHandler()
    }
  }

  func test_dispatchTimeInterval() {
    do {
      let leeway = TimerLeeway.zero
      expect(leeway.dispatchTimeInterval(from: 200)) == .nanoseconds(0)
    }

    do {
      let leeway = TimerLeeway.seconds(98)
      expect(leeway.dispatchTimeInterval(from: 200)) == .seconds(98)
    }

    do {
      let leeway = TimerLeeway.fractional(0.23)
      expect(leeway.dispatchTimeInterval(from: 200)) == .seconds(46)
    }

    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "leeway should be less than or equal to the firing interval."
      }
      let leeway = TimerLeeway.seconds(201)
      expect(leeway.dispatchTimeInterval(from: 200)) == .seconds(201)
      Assert.resetTestAssertionFailureHandler()
    }

    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "leeway percentage should be less than or equal to 1."
      }
      let leeway = TimerLeeway.fractional(1.1)
      expect(leeway.dispatchTimeInterval(from: 200)) == .seconds(220)
      Assert.resetTestAssertionFailureHandler()
    }
  }
}
