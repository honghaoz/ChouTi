//
//  DispatchTimeInterval+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/3/21.
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
