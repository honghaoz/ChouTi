//
//  DurationTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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

class DurationTests: XCTestCase {

  // MARK: - TimeInterval

  func test_zero_seconds() {
    expect(Duration.zero.seconds) == 0
  }

  func test_nanoseconds_seconds() {
    expect(Duration.nanoseconds(25).seconds) == 0.000000025
  }

  func test_microseconds_seconds() {
    expect(Duration.microseconds(25).seconds) == 0.000025
  }

  func test_milliseconds_seconds() {
    expect(Duration.milliseconds(25).seconds) == 0.025
  }

  func test_seconds_seconds() {
    expect(Duration.seconds(25).seconds) == 25
  }

  func test_minutes_seconds() {
    expect(Duration.minutes(25).seconds) == 1500 // 25 * 60
  }

  func test_hours_seconds() {
    expect(Duration.hours(25).seconds) == 90000 // 25 * 3600
  }

  func test_days_seconds() {
    expect(Duration.days(25).seconds) == 2160000 // 25 * 24 * 3600
  }

  func test_weeks_seconds() {
    expect(Duration.weeks(25).seconds) == 15120000 // 25 * 7 * 24 * 3600
  }

  func test_months_seconds() {
    expect(Duration.months(25).seconds) == 64800000 // 25 * 30 * 24 * 3600
  }

  func test_years_seconds() {
    expect(Duration.years(25).seconds) == 788400000 // 25 * 365 * 24 * 3600
  }

  func test_forever_seconds() {
    expect(Duration.forever.seconds) == .infinity
  }

  // MARK: - Milliseconds

  func test_zero_milliseconds() {
    expect(Duration.zero.milliseconds) == 0
  }

  func test_nanoseconds_milliseconds() {
    expect(Duration.nanoseconds(25).milliseconds).to(beApproximatelyEqual(to: 0.000025, within: 1e-9))
  }

  func test_microseconds_milliseconds() {
    expect(Duration.microseconds(25).milliseconds) == 0.025
  }

  func test_milliseconds_milliseconds() {
    expect(Duration.milliseconds(25).milliseconds) == 25
  }

  func test_seconds_milliseconds() {
    expect(Duration.seconds(25).milliseconds) == 25000 // 25 * 1000
  }

  func test_minutes_milliseconds() {
    expect(Duration.minutes(25).milliseconds) == 1500000 // 25 * 60 * 1000
  }

  func test_hours_milliseconds() {
    expect(Duration.hours(25).milliseconds) == 90000000 // 25 * 3600 * 1000
  }

  func test_forever_milliseconds() {
    expect(Duration.forever.milliseconds) == .infinity
  }

  // MARK: - Microseconds

  func test_zero_microseconds() {
    expect(Duration.zero.microseconds) == 0
  }

  func test_nanoseconds_microseconds() {
    expect(Duration.nanoseconds(25).microseconds).to(beApproximatelyEqual(to: 0.025, within: 1e-9))
  }

  func test_microseconds_microseconds() {
    expect(Duration.microseconds(25).microseconds) == 25
  }

  func test_milliseconds_microseconds() {
    expect(Duration.milliseconds(25).microseconds) == 25000 // 25 * 1000
  }

  func test_seconds_microseconds() {
    expect(Duration.seconds(25).microseconds) == 25000000 // 25 * 1000 * 1000
  }

  func test_minutes_microseconds() {
    expect(Duration.minutes(25).microseconds) == 1500000000 // 25 * 60 * 1000 * 1000
  }

  func test_hours_microseconds() {
    expect(Duration.hours(25).microseconds) == 90000000000 // 25 * 3600 * 1000 * 1000
  }

  func test_forever_microseconds() {
    expect(Duration.forever.microseconds) == .infinity
  }

  // MARK: - Nanoseconds

  func test_zero_nanoseconds() {
    expect(Duration.zero.nanoseconds) == 0
  }

  func test_nanoseconds_nanoseconds() {
    expect(Duration.nanoseconds(25).nanoseconds) == 25
  }

  func test_microseconds_nanoseconds() {
    expect(Duration.microseconds(25).nanoseconds) == 25000 // 25 * 1000
  }

  func test_milliseconds_nanoseconds() {
    expect(Duration.milliseconds(25).nanoseconds) == 25000000 // 25 * 1000 * 1000
  }

  func test_seconds_nanoseconds() {
    expect(Duration.seconds(25).nanoseconds) == 25000000000 // 25 * 1000 * 1000 * 1000
  }

  func test_minutes_nanoseconds() {
    expect(Duration.minutes(25).nanoseconds) == 1500000000000 // 25 * 60 * 1000 * 1000 * 1000
  }

  func test_hours_nanoseconds() {
    expect(Duration.hours(25).nanoseconds) == 90000000000000 // 25 * 3600 * 1000 * 1000 * 1000
  }

  func test_forever_nanoseconds() {
    expect(Duration.forever.nanoseconds) == .infinity
  }

  // MARK: - DispatchTimeInterval

  func testDispatchTimeInterval() {
    var duration = Duration.zero
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.nanoseconds(0)

    duration = .nanoseconds(10)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.nanoseconds(10)

    duration = Duration.microseconds(10)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.microseconds(10)

    duration = Duration.microseconds(10.2)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.nanoseconds(10200)

    duration = Duration.milliseconds(10)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.milliseconds(10)

    duration = Duration.milliseconds(10.6)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.nanoseconds(10600000)

    duration = Duration.seconds(20)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.seconds(20)

    duration = Duration.seconds(20.2)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.nanoseconds(20200000000)

    duration = Duration.minutes(10)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.seconds(600)

    duration = Duration.minutes(0.12 * 1e-6)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.nanoseconds(7200)

    duration = Duration.minutes(10.7)
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.seconds(642)

    duration = Duration.forever
    expect(duration.dispatchTimeInterval()) == DispatchTimeInterval.never

    do {
      // not exact, seconds
      let duration = Duration.seconds(0.12 * 1e-9)
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "inaccurate seconds conversion"
        expect(metadata) == ["amount": "1.2e-10"]
      }
      expect(duration.dispatchTimeInterval(assertIfNotExact: true)) == DispatchTimeInterval.nanoseconds(0)
      Assert.resetTestAssertionFailureHandler()
    }

    do {
      // not exact, milliseconds
      let duration = Duration.milliseconds(0.12 * 1e-6)
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "inaccurate milliseconds conversion"
        expect(metadata) == ["amount": "1.2e-07"]
      }
      expect(duration.dispatchTimeInterval(assertIfNotExact: true)) == DispatchTimeInterval.nanoseconds(0)
      Assert.resetTestAssertionFailureHandler()
    }

    do {
      // not exact, microseconds
      let duration = Duration.microseconds(0.12 * 1e-3)
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "inaccurate microseconds conversion"
        expect(metadata) == ["amount": "0.00012"]
      }
      expect(duration.dispatchTimeInterval(assertIfNotExact: true)) == DispatchTimeInterval.nanoseconds(0)
      Assert.resetTestAssertionFailureHandler()
    }

    do {
      // not exact, nanoseconds
      let duration = Duration.nanoseconds(10.4)
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "inaccurate nanoseconds conversion"
        expect(metadata) == ["amount": "10.4"]
      }
      expect(duration.dispatchTimeInterval(assertIfNotExact: true)) == DispatchTimeInterval.nanoseconds(10)
      Assert.resetTestAssertionFailureHandler()
    }

    do {
      // not exact, minutes
      let duration = Duration.minutes(0.12 * 1e-9)
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "inaccurate seconds conversion"
        expect(metadata) == ["amount": "7.2e-09"]
      }
      expect(duration.dispatchTimeInterval(assertIfNotExact: true)) == DispatchTimeInterval.nanoseconds(7)
      Assert.resetTestAssertionFailureHandler()
    }
  }

  // MARK: - Comparable

  func testLessThan() {
    expect(Duration.seconds(1)).to(beLessThan(Duration.seconds(2)))
    expect(Duration.seconds(2)) >= Duration.seconds(1)

    expect(Duration.seconds(1)) < Duration.minutes(1)
    expect(Duration.seconds(1)) < Duration.hours(1)
  }

  func testGreaterThan() {
    expect(Duration.seconds(2)) > Duration.seconds(1)
    expect(Duration.seconds(1)) <= Duration.seconds(2)

    expect(Duration.minutes(1)) > Duration.seconds(1)
    expect(Duration.hours(1)) > Duration.seconds(1)
  }

  func testAdding() {
    let date = Date(timeIntervalSince1970: 1598249449) // Aug 23, 23:10 PM in Pacific Time.

    let oneHourLater = date.adding(.hours(1))
    expect(oneHourLater.timeIntervalSince1970) == 1598253049

    expect(date.adding(60 * 60).timeIntervalSince1970) == 1598253049
  }

  func testSubtracting() {
    let date = Date(timeIntervalSince1970: 1598249449) // Aug 23, 23:10 PM in Pacific Time.

    let oneHourAgo = date.subtracting(.hours(2))
    expect(oneHourAgo.timeIntervalSince1970) == 1598242249

    let twoSecondsAgo = date.subtracting(2)
    expect(twoSecondsAgo.timeIntervalSince1970) == 1598249447
  }

  func testHasBeen() {
    let date1 = Date(timeIntervalSince1970: 1598249449) // Aug 23, 23:10:49 PM in Pacific Time.
    let date2 = Date(timeIntervalSince1970: 1598249439) // Aug 23, 23:10:39 PM in Pacific Time.
    expect(date1.hasBeen(.seconds(10), since: date2)) == true
    expect(date1.hasBeen(.seconds(11), since: date2)) == false
  }
}
