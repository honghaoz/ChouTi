//
//  AngleTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 12/21/22.
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

class AngleTests: XCTestCase {

  func test_zero() {
    let angle = Angle.zero
    expect(angle.degrees) == 0
    expect(angle.radians) == 0
  }

  func test_static_init() {
    do {
      let angle = Angle.degrees(90.5)
      expect(angle.degrees) == 90.5
      expect(angle.radians) == 90.5 * .pi / 180
    }

    do {
      let angle = Angle.degrees(90)
      expect(angle.degrees) == 90
      expect(angle.radians) == .pi / 2
    }

    do {
      let angle = Angle.radians(.pi)
      expect(angle.radians) == .pi
      expect(angle.degrees) == 180
    }

    do {
      let angle = Angle.radians(1)
      expect(angle.radians) == 1
      expect(angle.degrees) == 180 / .pi
    }
  }

  func test_init_degrees() {
    let angle = Angle(degrees: 90)
    expect(angle.degrees) == 90
    expect(angle.radians) == .pi / 2
  }

  func test_init_radians() {
    let angle = Angle(radians: .pi)
    expect(angle.radians) == .pi
    expect(angle.degrees) == 180
  }

  func test_add() {
    do {
      let angle1 = Angle(degrees: 90)
      let angle2 = Angle(degrees: 90)
      let angle3 = angle1 + angle2
      expect(angle3.degrees) == 180
    }

    do {
      let angle1 = Angle(degrees: 90)
      let angle2 = Angle(radians: .pi)
      let angle3 = angle1 + angle2
      expect(angle3.degrees) == 270
    }
  }

  func test_subtract() {
    do {
      let angle1 = Angle(degrees: 90)
      let angle2 = Angle(degrees: 90)
      let angle3 = angle1 - angle2
      expect(angle3.degrees) == 0
    }

    do {
      let angle1 = Angle(degrees: 90)
      let angle2 = Angle(radians: .pi)
      let angle3 = angle1 - angle2
      expect(angle3.degrees) == -90
    }
  }

  func test_add_assign() {
    do {
      var angle1 = Angle(degrees: 90)
      let angle2 = Angle(degrees: 90)
      angle1 += angle2
      expect(angle1.degrees) == 180
    }

    do {
      var angle1 = Angle(degrees: 90)
      let angle2 = Angle(radians: .pi / 2)
      angle1 += angle2
      expect(angle1.degrees) == 180
    }
  }

  func test_subtract_assign() {
    do {
      var angle1 = Angle(degrees: 90)
      let angle2 = Angle(degrees: 90)
      angle1 -= angle2
      expect(angle1.degrees) == 0
    }

    do {
      var angle1 = Angle(degrees: 90)
      let angle2 = Angle(radians: .pi / 2)
      angle1 -= angle2
      expect(angle1.degrees) == 0
    }
  }

  func test_negate() {
    let angle = Angle(degrees: 90)
    let negatedAngle = -angle
    expect(negatedAngle.degrees) == -90
  }

  func test_comparable() {
    let angle1 = Angle(degrees: 90)
    let angle2 = Angle(degrees: 180)
    expect(angle1 < angle2) == true
    expect(angle2 < angle1) == false
  }

  func test_integerLiteral() {
    let angle: Angle = 90
    expect(angle.degrees) == 90
  }

  func test_floatLiteral() {
    let angle: Angle = 90.0
    expect(angle.degrees) == 90
  }
}
