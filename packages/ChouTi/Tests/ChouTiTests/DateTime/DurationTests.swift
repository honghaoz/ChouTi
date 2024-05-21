//
//  DurationTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class DurationTests: XCTestCase {

  // MARK: - TimeInterval

  func test_zero_seconds() {
    XCTAssertEqual(Duration.zero.seconds, 0)
  }

  func test_nanoseconds_seconds() {
    XCTAssertEqual(Duration.nanoseconds(25).seconds, 0.000000025)
  }

  func test_microseconds_seconds() {
    XCTAssertEqual(Duration.microseconds(25).seconds, 0.000025)
  }

  func test_milliseconds_seconds() {
    XCTAssertEqual(Duration.milliseconds(25).seconds, 0.025)
  }

  func test_seconds_seconds() {
    XCTAssertEqual(Duration.seconds(25).seconds, 25)
  }

  func test_minutes_seconds() {
    XCTAssertEqual(Duration.minutes(25).seconds, 25 * 60)
  }

  func test_hours_seconds() {
    XCTAssertEqual(Duration.hours(25).seconds, 25 * 3600)
  }

  func test_days_seconds() {
    XCTAssertEqual(Duration.days(25).seconds, 25 * 24 * 3600)
  }

  func test_weeks_seconds() {
    XCTAssertEqual(Duration.weeks(25).seconds, 25 * 7 * 24 * 3600)
  }

  func test_months_seconds() {
    XCTAssertEqual(Duration.months(25).seconds, 25 * 30 * 24 * 3600)
  }

  func test_years_seconds() {
    XCTAssertEqual(Duration.years(25).seconds, 25 * 365 * 24 * 3600)
  }

  func test_forever_seconds() {
    XCTAssertEqual(Duration.forever.seconds, .infinity)
  }

  // MARK: - Milliseconds

  func test_zero_milliseconds() {
    XCTAssertEqual(Duration.zero.milliseconds, 0)
  }

  func test_nanoseconds_milliseconds() {
    XCTAssertEqual(Duration.nanoseconds(25).milliseconds, 0.000025, accuracy: 1e-9)
  }

  func test_microseconds_milliseconds() {
    XCTAssertEqual(Duration.microseconds(25).milliseconds, 0.025)
  }

  func test_milliseconds_milliseconds() {
    XCTAssertEqual(Duration.milliseconds(25).milliseconds, 25)
  }

  func test_seconds_milliseconds() {
    XCTAssertEqual(Duration.seconds(25).milliseconds, 25 * 1000)
  }

  func test_minutes_milliseconds() {
    XCTAssertEqual(Duration.minutes(25).milliseconds, 25 * 60 * 1000)
  }

  func test_hours_milliseconds() {
    XCTAssertEqual(Duration.hours(25).milliseconds, 25 * 3600 * 1000)
  }

  func test_forever_milliseconds() {
    XCTAssertEqual(Duration.forever.milliseconds, .infinity)
  }

  // MARK: - Microseconds

  func test_zero_microseconds() {
    XCTAssertEqual(Duration.zero.microseconds, 0)
  }

  func test_nanoseconds_microseconds() {
    XCTAssertEqual(Duration.nanoseconds(25).microseconds, 0.025, accuracy: 1e-9)
  }

  func test_microseconds_microseconds() {
    XCTAssertEqual(Duration.microseconds(25).microseconds, 25)
  }

  func test_milliseconds_microseconds() {
    XCTAssertEqual(Duration.milliseconds(25).microseconds, 25 * 1000)
  }

  func test_seconds_microseconds() {
    XCTAssertEqual(Duration.seconds(25).microseconds, 25 * 1000 * 1000)
  }

  func test_minutes_microseconds() {
    XCTAssertEqual(Duration.minutes(25).microseconds, 25 * 60 * 1000 * 1000)
  }

  func test_hours_microseconds() {
    XCTAssertEqual(Duration.hours(25).microseconds, 25 * 3600 * 1000 * 1000)
  }

  func test_forever_microseconds() {
    XCTAssertEqual(Duration.forever.microseconds, .infinity)
  }

  // MARK: - Nanoseconds

  func test_zero_nanoseconds() {
    XCTAssertEqual(Duration.zero.nanoseconds, 0)
  }

  func test_nanoseconds_nanoseconds() {
    XCTAssertEqual(Duration.nanoseconds(25).nanoseconds, 25)
  }

  func test_microseconds_nanoseconds() {
    XCTAssertEqual(Duration.microseconds(25).nanoseconds, 25 * 1000)
  }

  func test_milliseconds_nanoseconds() {
    XCTAssertEqual(Duration.milliseconds(25).nanoseconds, 25 * 1000 * 1000)
  }

  func test_seconds_nanoseconds() {
    XCTAssertEqual(Duration.seconds(25).nanoseconds, 25 * 1000 * 1000 * 1000)
  }

  func test_minutes_nanoseconds() {
    XCTAssertEqual(Duration.minutes(25).nanoseconds, 25 * 60 * 1000 * 1000 * 1000)
  }

  func test_hours_nanoseconds() {
    XCTAssertEqual(Duration.hours(25).nanoseconds, 25 * 3600 * 1000 * 1000 * 1000)
  }

  func test_forever_nanoseconds() {
    XCTAssertEqual(Duration.forever.nanoseconds, .infinity)
  }

  // MARK: - DispatchTimeInterval

  func testDispatchTimeInterval() {
    var duration = Duration.nanoseconds(10)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.nanoseconds(10))

    duration = Duration.nanoseconds(10.4)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.nanoseconds(10))

    duration = Duration.microseconds(10)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.microseconds(10))

    duration = Duration.microseconds(10.2)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.nanoseconds(10200))

    duration = Duration.milliseconds(10)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.milliseconds(10))

    duration = Duration.milliseconds(10.6)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.nanoseconds(10600000))

    duration = Duration.seconds(20)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.seconds(20))

    duration = Duration.seconds(20.2)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.nanoseconds(20200000000))

    duration = Duration.minutes(10)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.seconds(600))

    duration = Duration.minutes(10.7)
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.seconds(642))

    duration = Duration.forever
    XCTAssertEqual(duration.dispatchTimeInterval(), DispatchTimeInterval.never)
  }

  // MARK: - Comparable

  func testLessThan() {
    XCTAssert(Duration.seconds(1) < Duration.seconds(2))
    XCTAssertFalse(Duration.seconds(2) < Duration.seconds(1))

    XCTAssert(Duration.seconds(1) < Duration.minutes(1))
    XCTAssert(Duration.seconds(1) < Duration.hours(1))
  }

  func testGreaterThan() {
    XCTAssert(Duration.seconds(2) > Duration.seconds(1))
    XCTAssertFalse(Duration.seconds(1) > Duration.seconds(2))

    XCTAssert(Duration.minutes(1) > Duration.seconds(1))
    XCTAssert(Duration.hours(1) > Duration.seconds(1))
  }

  // TODO: to restore

//  func testAdding() {
//    let date = Date(timeIntervalSince1970: 1598249449) // Aug 23, 23:10 PM in Pacific Time.
//
//    let oneHourLater = date.adding(.hours(1))
//    XCTAssertEqual(oneHourLater.day(in: .losAngeles), 24)
//    XCTAssertEqual(oneHourLater.hour(in: .losAngeles), 0)
//    XCTAssertEqual(oneHourLater.minute(in: .losAngeles), 10)
//    XCTAssertEqual(oneHourLater.second(in: .losAngeles), 49)
//  }
//
//  func testSubtracting() {
//    let date = Date(timeIntervalSince1970: 1598249449) // Aug 23, 23:10 PM in Pacific Time.
//
//    let oneHourAgo = date.subtracting(.hours(2))
//    XCTAssertEqual(oneHourAgo.day(in: .losAngeles), 23)
//    XCTAssertEqual(oneHourAgo.hour(in: .losAngeles), 21)
//    XCTAssertEqual(oneHourAgo.minute(in: .losAngeles), 10)
//    XCTAssertEqual(oneHourAgo.second(in: .losAngeles), 49)
//
//    let twoSecondsAgo = date.subtracting(2)
//    XCTAssertEqual(twoSecondsAgo.second(in: .losAngeles), 47)
//  }
//
//  func testHasBeen() {
//    let date1 = Date(timeIntervalSince1970: 1598249449) // Aug 23, 23:10:49 PM in Pacific Time.
//    let date2 = Date(timeIntervalSince1970: 1598249439) // Aug 23, 23:10:39 PM in Pacific Time.
//    XCTAssertTrue(date1.hasBeen(.seconds(10), since: date2))
//    XCTAssertFalse(date1.hasBeen(.seconds(11), since: date2))
//  }
}