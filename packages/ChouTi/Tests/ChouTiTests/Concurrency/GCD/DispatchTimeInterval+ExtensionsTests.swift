//
//  DispatchTimeInterval+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
@testable import ChouTi

class DispatchTimeInterval_ExtensionsTests: XCTestCase {

  func testTimeIntervalToDispatchTimeInterval() {
    let interval: TimeInterval = 3
    let dispatchTimeInterval = interval.dispatchTimeInterval()
    let convertedInterval = dispatchTimeInterval.timeInterval
    XCTAssertEqual(interval, convertedInterval, accuracy: 0.000001)
  }

  func testNilTimeInterval() {
    let convertedIntervalSeconds = DispatchTimeInterval.seconds(10).timeInterval
    XCTAssertEqual(convertedIntervalSeconds, 10)

    let convertedIntervalMilliseconds = DispatchTimeInterval.milliseconds(10001).timeInterval
    XCTAssertEqual(convertedIntervalMilliseconds, 10.001)

    let convertedIntervalMicroseconds = DispatchTimeInterval.microseconds(10001).timeInterval
    XCTAssertEqual(convertedIntervalMicroseconds, 0.010001)

    let convertedIntervalNanoseconds = DispatchTimeInterval.nanoseconds(10001).timeInterval
    XCTAssertEqual(convertedIntervalNanoseconds, 0.000010001)

    let convertedIntervalNever = DispatchTimeInterval.never.timeInterval
    XCTAssertEqual(convertedIntervalNever, .greatestFiniteMagnitude)
  }
}
