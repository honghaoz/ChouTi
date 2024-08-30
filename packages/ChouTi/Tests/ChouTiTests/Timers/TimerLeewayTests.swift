//
//  TimerLeewayTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/22.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
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
