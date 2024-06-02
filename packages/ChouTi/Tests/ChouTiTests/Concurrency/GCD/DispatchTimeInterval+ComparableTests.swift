//
//  DispatchTimeInterval+ComparableTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class DispatchTimeInterval_ComparableTests: XCTestCase {

  func test_lessThan() {
    expect(DispatchTimeInterval.seconds(1)) < DispatchTimeInterval.seconds(2)
    expect(DispatchTimeInterval.seconds(1)) < DispatchTimeInterval.milliseconds(1001)
    expect(DispatchTimeInterval.seconds(1)) < DispatchTimeInterval.microseconds(1000001)
    expect(DispatchTimeInterval.seconds(Int(1e9))) < DispatchTimeInterval.never
  }

  func test_greaterThan() {
    expect(DispatchTimeInterval.seconds(2)) > DispatchTimeInterval.seconds(1)
    expect(DispatchTimeInterval.seconds(1)) >= DispatchTimeInterval.seconds(1)
    expect(DispatchTimeInterval.seconds(1)) >= DispatchTimeInterval.milliseconds(1000)
    expect(DispatchTimeInterval.seconds(1)) > DispatchTimeInterval.milliseconds(999)
    expect(DispatchTimeInterval.seconds(1)) >= DispatchTimeInterval.microseconds(1000000)
    expect(DispatchTimeInterval.seconds(1)) > DispatchTimeInterval.microseconds(999999)
    expect(DispatchTimeInterval.seconds(1)) >= DispatchTimeInterval.nanoseconds(1000000000)
    expect(DispatchTimeInterval.seconds(1)) > DispatchTimeInterval.nanoseconds(999999999)
  }
}
