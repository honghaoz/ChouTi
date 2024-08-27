//
//  ClampTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class ClampTests: XCTestCase {

  func test_clamp_closedRange() {
    expect(150.clamped(to: 0 ... 100)) == 100
    expect(99.clamped(to: 0 ... 100)) == 99
    expect((-20).clamped(to: 0 ... 100)) == 0

    var num = 150
    num.clamping(to: 0 ... 100)
    expect(num) == 100
  }

  func test_clamp_partialRange() {
    expect(120.clamped(to: 0...)) == 120
    expect(120.clamped(to: 130...)) == 130

    expect(120.clamped(to: ...150)) == 120
    expect(150.clamped(to: ...100)) == 100

    var num = 120
    num.clamping(to: 0...)
    expect(num) == 120

    num = 120
    num.clamping(to: 130...)
    expect(num) == 130

    num = 120
    num.clamping(to: ...150)
    expect(num) == 120

    num = 120
    num.clamping(to: ...100)
    expect(num) == 100
  }

  func test_clamp_int() {
    expect(10.clamped(to: 0 ..< 10)) == 9
    expect(10.clamped(to: 0 ..< 15)) == 10

    var num = 10
    num.clamping(to: 0 ..< 10)
    expect(num) == 9
  }
}
