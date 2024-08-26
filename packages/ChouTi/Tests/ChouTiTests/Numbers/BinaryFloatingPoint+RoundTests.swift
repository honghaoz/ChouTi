//
//  BinaryFloatingPoint+RoundTests.swift
//
//  Created by Honghao Zhang on 9/6/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import ChouTi

class BinaryFloatingPoint_RoundTests: XCTestCase {

  func testRound() {
    expect(CGFloat(3).round(nearest: 0.5)) == CGFloat(3)
    expect(CGFloat(3.1).round(nearest: 0.5)) == CGFloat(3)
    expect(CGFloat(3.2).round(nearest: 0.5)) == CGFloat(3)
    expect(CGFloat(3.25).round(nearest: 0.5)) == CGFloat(3.5)
    expect(CGFloat(3.3).round(nearest: 0.5)) == CGFloat(3.5)
    expect(CGFloat(3.4).round(nearest: 0.5)) == CGFloat(3.5)
    expect(CGFloat(3.7).round(nearest: 0.5)) == CGFloat(3.5)
    expect(CGFloat(3.75).round(nearest: 0.5)) == CGFloat(4)
    expect(CGFloat(3.8).round(nearest: 0.5)) == CGFloat(4)

    expect(CGFloat(0.1).round(nearest: 0.5)) == CGFloat(0)
    expect(CGFloat(-0.1).round(nearest: 0.5)) == CGFloat(0)
    expect(CGFloat(-0.3).round(nearest: 0.5)) == CGFloat(-0.5)

    // From real world examples
    expect(CGFloat(50.666666666666664).round(nearest: 0.33333333333333331)) == CGFloat(50.666666666666664)
    expect(CGFloat(0.66666666666666607).round(nearest: 0.33333333333333331)) == CGFloat(0.6666666666666666)
  }

  func testCeil() {
    // rounded number should be untouched
    expect(CGFloat(47).ceil(nearest: 0.5)) == CGFloat(47)
    expect(CGFloat(47.1).ceil(nearest: 0.5)) == CGFloat(47.5)
    expect(CGFloat(47.4).ceil(nearest: 0.5)) == CGFloat(47.5)
    expect(CGFloat(47.5).ceil(nearest: 0.5)) == CGFloat(47.5)
    expect(CGFloat(47.6).ceil(nearest: 0.5)) == CGFloat(48)

    let pixelWidth: CGFloat = 1 / 3.0

    expect(CGFloat(3.6666666666666665).ceil(nearest: pixelWidth)) == CGFloat(3.6666666666666665)
    expect((3 + pixelWidth).ceil(nearest: pixelWidth)) == 3 + pixelWidth

    expect(CGFloat(3.7).ceil(nearest: pixelWidth)) == CGFloat(4)
    expect(CGFloat(3.4).ceil(nearest: pixelWidth)) == CGFloat(3.6666666666666665)

    expect(CGFloat(375).ceil(nearest: pixelWidth)) == CGFloat(375)

    expect(CGFloat(50.666666666666664).ceil(nearest: 0.33333333333333331)) == CGFloat(50.666666666666664)
    expect(CGFloat(0.66666666666666607).ceil(nearest: 0.33333333333333331)) == CGFloat(0.6666666666666666)
  }

  func testFloor() {
    // rounded number should be untouched
    expect(CGFloat(47).floor(nearest: 0.5)) == CGFloat(47)
    expect(CGFloat(47.1).floor(nearest: 0.5)) == CGFloat(47)
    expect(CGFloat(47.4).floor(nearest: 0.5)) == CGFloat(47)
    expect(CGFloat(47.5).floor(nearest: 0.5)) == CGFloat(47.5)
    expect(CGFloat(47.6).floor(nearest: 0.5)) == CGFloat(47.5)
    expect(CGFloat(47.8).floor(nearest: 0.5)) == CGFloat(47.5)
    expect(CGFloat(48).floor(nearest: 0.5)) == CGFloat(48)

    expect(CGFloat(3.7).floor(nearest: 0.5)) == CGFloat(3.5)
    expect(CGFloat(3.4).floor(nearest: 0.5)) == CGFloat(3)

    expect(CGFloat(3.7).floor(nearest: 0.5)) == CGFloat(3.5)
    expect(CGFloat(3.4).floor(nearest: 0.5)) == CGFloat(3)

    expect(CGFloat(3.7).floor(nearest: 1 / 3)) == CGFloat(3.6666666666666665)
    expect(CGFloat(3.4).floor(nearest: 1 / 3)) == CGFloat(3.333333333333333)

    expect(CGFloat(50.666666666666664).floor(nearest: 0.33333333333333331)) == CGFloat(50.666666666666664)
    expect(CGFloat(0.66666666666666607).floor(nearest: 0.33333333333333331)) == CGFloat(0.33333333333333331)
  }
}
