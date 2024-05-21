//
//  TimerLeewayTests.swift
//
//  Created by Honghao Zhang on 11/13/22.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
import ChouTi

class TimerLeewayTests: XCTestCase {

  func test() {
    var leeway = TimerLeeway.seconds(98)
    XCTAssertEqual(leeway.dispatchTimeInterval(from: 200), .seconds(98))

    leeway = TimerLeeway.zero
    XCTAssertEqual(leeway.dispatchTimeInterval(from: 200), .nanoseconds(0))

    leeway = TimerLeeway.fractional(0.23)
    XCTAssertEqual(leeway.dispatchTimeInterval(from: 200), .seconds(46))
  }
}
