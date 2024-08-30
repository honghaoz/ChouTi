//
//  ClampTests.swift
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
