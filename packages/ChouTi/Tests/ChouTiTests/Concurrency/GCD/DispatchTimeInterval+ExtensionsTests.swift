//
//  DispatchTimeInterval+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class DispatchTimeInterval_ExtensionsTests: XCTestCase {

  func testTimeIntervalToDispatchTimeInterval() {
    let interval: TimeInterval = 3
    let dispatchTimeInterval = interval.dispatchTimeInterval()
    let convertedInterval = dispatchTimeInterval.timeInterval
    expect(interval).to(beApproximatelyEqual(to: convertedInterval, within: 0.000001))
  }

  func testNilTimeInterval() {
    let convertedIntervalSeconds = DispatchTimeInterval.seconds(10).timeInterval
    expect(convertedIntervalSeconds) == 10

    let convertedIntervalMilliseconds = DispatchTimeInterval.milliseconds(10001).timeInterval
    expect(convertedIntervalMilliseconds) == 10.001

    let convertedIntervalMicroseconds = DispatchTimeInterval.microseconds(10001).timeInterval
    expect(convertedIntervalMicroseconds) == 0.010001

    let convertedIntervalNanoseconds = DispatchTimeInterval.nanoseconds(10001).timeInterval
    expect(convertedIntervalNanoseconds) == 0.000010001

    let convertedIntervalNever = DispatchTimeInterval.never.timeInterval
    expect(convertedIntervalNever) == .greatestFiniteMagnitude
  }
}
