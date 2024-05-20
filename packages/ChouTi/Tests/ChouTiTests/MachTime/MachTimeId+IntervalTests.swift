//
//  MachTimeId+IntervalTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

import XCTest

import ChouTi

final class MachTimeId_IntervalTests: XCTestCase {

  func testMachTimeInterval() {
    let start: UInt64 = 1000000
    let end: UInt64 = 2000000
    let interval = machTimeInterval(from: start, to: end)
    XCTAssertGreaterThan(interval, 0)
  }

  func testMachTimeIdIntervalSince() {
    let start: MachTimeId = 1000000
    let end: MachTimeId = 2000000
    let interval = end.interval(since: start)
    XCTAssertGreaterThan(interval, 0)
  }

  func testMachTimeIdIntervalWithMachAbsoluteTime() {
    let start = MachTimeId.id()
    // Simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }
    let end = MachTimeId.id()
    let interval = end.interval(since: start)

    XCTAssertGreaterThan(interval, 0)
  }

  func testMachTimeIntervalWithMachAbsoluteTime() {
    let start = mach_absolute_time()
    // Simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }
    let end = mach_absolute_time()
    let interval = machTimeInterval(from: start, to: end)

    XCTAssertGreaterThan(interval, 0)
  }
}
