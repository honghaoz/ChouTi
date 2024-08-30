//
//  CGPoint+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2019-07-11.
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

class CGPoint_ExtensionsTests: XCTestCase {

  func test_init() {
    let point = CGPoint(10, 20)
    expect(point) == CGPoint(x: 10, y: 20)
  }

  func test_midPoint() {
    let p1 = CGPoint(x: 10, y: 20)
    let p2 = CGPoint(x: 100, y: 50)
    let midPoint = CGPoint.midPoint(p1: p1, p2: p2)
    expect(midPoint) == CGPoint(x: 55, y: 35)
  }

  func test_translate() {
    let point = CGPoint(x: 10, y: 20)
    expect(point.translate(dx: 5, dy: 10)) == CGPoint(x: 15, y: 30)
    expect(point.translate(CGVector(dx: 5, dy: 10))) == CGPoint(x: 15, y: 30)
    expect(point.translate(CGPoint(x: 5, y: 10))) == CGPoint(x: 15, y: 30)
  }

  func test_distance() {
    do {
      let point1 = CGPoint(x: 10, y: 20)
      let point2 = CGPoint(x: 100, y: 50)
      expect(point1.distance(to: point2)).to(beApproximatelyEqual(to: 94.86832980505137, within: 1e-5))
    }

    do {
      let point1 = CGPoint(x: 0, y: 0)
      let point2 = CGPoint(x: 0, y: 50)
      expect(point1.distance(to: point2)) == 50
    }
  }

  func test_lerp() {
    let point1 = CGPoint(x: 10, y: 20)
    let point2 = CGPoint(x: 100, y: 50)
    expect(point1.lerp(endPoint: point2, t: 0.5)) == CGPoint(x: 55, y: 35)
  }

  func test_negate() {
    let point = CGPoint(x: 10, y: 20)
    expect(-point) == CGPoint(x: -10, y: -20)
  }

  func test_add() {
    let point1 = CGPoint(x: 10, y: 20)
    let point2 = CGPoint(x: 100, y: 50)
    expect(point1 + point2) == CGPoint(x: 110, y: 70)
  }

  func test_subtract() {
    let point1 = CGPoint(x: 10, y: 20)
    let point2 = CGPoint(x: 100, y: 50)
    expect(point1 - point2) == CGPoint(x: -90, y: -30)
  }

  func test_multiply() {
    var point = CGPoint(x: 10, y: 20)
    expect(point * 2) == CGPoint(x: 20, y: 40)

    point *= 2
    expect(point) == CGPoint(x: 20, y: 40)
  }

  func test_flipped() {
    let point = CGPoint(x: 10, y: 20)
    expect(point.flipped(containerHeight: 100)) == CGPoint(x: 10, y: 80)
  }

  func test_asVector() {
    let point = CGPoint(x: 10, y: 20)
    expect(point.asVector()) == CGVector(dx: 10, dy: 20)
  }

  func testApproximatelyEqual() {
    let pixelSize = 1 / CGFloat(3)
    let absoluteTolerance = pixelSize + 1e-12

    let p1 = CGPoint(187.33333333333331, 135.66666666666666)
    let p2 = CGPoint(187.66666666666666, 135.66666666666666)
    expect(p1.isApproximatelyEqual(to: p2, absoluteTolerance: absoluteTolerance)) == true
  }

  func testHashable() {
    let p1 = CGPoint(187, 135)
    let p2 = CGPoint(187, 135)
    expect(p1.hashValue) == p2.hashValue

    let p3 = CGPoint(187.33333333333331, 135.66666666666666)
    expect(p1.hashValue) != p3.hashValue
  }
}
