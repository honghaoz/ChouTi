//
//  DispatchTimeInterval+ComparableTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
import ChouTi

class DispatchTimeInterval_ComparableTests: XCTestCase {

  func testEqual() {
    let intervalSeconds1 = DispatchTimeInterval.seconds(10)
    let intervalSeconds2 = DispatchTimeInterval.seconds(10)
    XCTAssertTrue(intervalSeconds1 == intervalSeconds2)

    let intervalMilliseconds1 = DispatchTimeInterval.milliseconds(10)
    let intervalMilliseconds2 = DispatchTimeInterval.milliseconds(10)
    XCTAssertTrue(intervalMilliseconds1 == intervalMilliseconds2)
  }

  func testGreaterThan() {
    let intervalSeconds1 = DispatchTimeInterval.seconds(11)
    let intervalSeconds2 = DispatchTimeInterval.seconds(10)
    XCTAssertTrue(intervalSeconds1 > intervalSeconds2)

    let intervalMilliseconds1 = DispatchTimeInterval.milliseconds(11)
    let intervalMilliseconds2 = DispatchTimeInterval.milliseconds(10)
    XCTAssertTrue(intervalMilliseconds1 > intervalMilliseconds2)

    let intervalMilliseconds11 = DispatchTimeInterval.milliseconds(1001)
    let intervalMilliseconds22 = DispatchTimeInterval.seconds(1)
    XCTAssertTrue(intervalMilliseconds11 > intervalMilliseconds22)
  }
}
