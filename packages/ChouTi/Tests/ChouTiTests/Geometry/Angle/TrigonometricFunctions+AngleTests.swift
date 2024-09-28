//
//  TrigonometricFunctions+AngleTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/2/24.
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

final class TrigonometricFunctionsAngleTests: XCTestCase {

  func test_sin() {
    expect(sin(.degrees(30))) == 0.49999999999999994
    expect(sin(.degrees(45))) == 0.7071067811865475
    expect(sin(.degrees(60))) == 0.8660254037844386
    expect(sin(.degrees(90))) == 1.0

    expect(sin(.radians(0))) == 0.0
    expect(sin(.radians(.pi / 2))) == 1.0
    expect(sin(.radians(.pi))) == 1.2246467991473532e-16
    expect(sin(.pi)) == 1.2246467991473532e-16
    expect(sin(.radians(3 * .pi / 2))) == -1.0
    expect(sin(.radians(2 * .pi))) == -2.4492935982947064e-16
  }

  func test_cos() {
    expect(cos(.degrees(30))) == 0.8660254037844387
    expect(cos(.degrees(45))) == 0.7071067811865476
    expect(cos(.degrees(60))) == 0.5000000000000001
    expect(cos(.degrees(90))) == 6.123233995736766e-17

    expect(cos(.radians(0))) == 1.0
    expect(cos(.radians(.pi / 2))) == 6.123233995736766e-17
    expect(cos(.radians(.pi))) == -1.0
    expect(cos(.radians(3 * .pi / 2))) == -1.8369701987210297e-16
    expect(cos(.radians(2 * .pi))) == 1.0
  }

  func test_tan() {
    expect(tan(.degrees(30))) == 0.5773502691896256
    expect(tan(.degrees(45))) == 0.9999999999999999
    expect(tan(.degrees(60))) == 1.7320508075688767
    expect(tan(.degrees(90))) == 1.633123935319537e+16

    expect(tan(.radians(0))) == 0.0
    expect(tan(.radians(.pi / 2))) == 1.633123935319537e+16
    expect(tan(.radians(.pi))) == -1.2246467991473532e-16
    expect(tan(.radians(3 * .pi / 2))) == 5443746451065123.0
    expect(tan(.radians(2 * .pi))) == -2.4492935982947064e-16
  }

  func test_asin() {
    expect(asin(0.5)) == .degrees(29.999999999999996)
    expect(asin(1.0)) == .degrees(90)
    expect(asin(0.0)) == .degrees(0)
    expect(asin(-1.0)) == .degrees(-90)
  }

  func test_acos() {
    expect(acos(0.5)) == .degrees(59.99999999999999)
    expect(acos(1.0)) == .degrees(0)
    expect(acos(0.0)) == .degrees(90)
    expect(acos(-1.0)) == .degrees(180)
  }

  func test_atan() {
    expect(atan(0.5)) == .degrees(26.56505117707799)
    expect(atan(1.0)) == .degrees(45)
    expect(atan(0.0)) == .degrees(0)
    expect(atan(-1.0)) == .degrees(-45)
  }
}
