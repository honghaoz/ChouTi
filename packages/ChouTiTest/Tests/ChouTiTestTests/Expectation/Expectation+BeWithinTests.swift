//
//  Expectation+BeWithinTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/11/26.
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
import XCTest

import Foundation

class Expectation_BeWithinTests: XCTestCase {

  func test_beWithin_closedRange() {
    expect(1).to(beWithin(1 ... 3))
    expect(2).to(beWithin(1 ... 3))
    expect(3).to(beWithin(1 ... 3))
    expect(0).toNot(beWithin(1 ... 3))
    expect(4).toNot(beWithin(1 ... 3))
    expect(1.5).to(beWithin(1 ... 2))
    expect("b").to(beWithin("a" ... "c"))
    expect(beWithin(1 ... 3).description) == #"be within "1...3""#
  }

  func test_beWithin_halfOpenRange() {
    expect(1).to(beWithin(1 ..< 3))
    expect(2).to(beWithin(1 ..< 3))
    expect(3).toNot(beWithin(1 ..< 3))
    expect(0).toNot(beWithin(1 ..< 3))
    expect(beWithin(1 ..< 3).description) == #"be within "1..<3""#
  }

  func test_beBetween() {
    expect(2).to(beBetween(1, and: 3))
    expect(2).to(beBetween(3, and: 1))
    expect(1).to(beBetween(3, and: 1))
    expect(3).to(beBetween(3, and: 1))
    expect(2).to(beBetween(2, and: 2))
    expect(0).toNot(beBetween(3, and: 1))
    expect(4).toNot(beBetween(3, and: 1))
    expect(beBetween(3, and: 1).description) == #"be within "1...3""#
  }

  func test_beBetween_withTolerance() {
    expect(0.5).to(beBetween(1.0, and: 2.0, within: 0.5))
    expect(2.5).to(beBetween(2.0, and: 1.0, within: 0.5))
    expect(1.5).to(beBetween(1.5, and: 1.5, within: 0))
    expect(0.25).toNot(beBetween(1.0, and: 2.0, within: 0.5))
    expect(2.75).toNot(beBetween(1.0, and: 2.0, within: 0.5))
    expect(beBetween(2.0, and: 1.0, within: 0.5).description) == #"be within "0.5...2.5""#
  }

  func test_optionalAndEventually() {
    let value: Int? = 2
    let nilValue: Int? = nil

    expect(value).to(beWithin(1 ... 3))
    expect(nilValue).toNot(beWithin(1 ... 3))
    expect(2).toEventually(beBetween(3, and: 1))
    expect(0).toEventuallyNot(beWithin(1 ..< 3))
  }
}

class Expectation_BeWithinFailureMessageTests: FailureCapturingTestCase {

  func test_beWithin() {
    expect(4).to(beWithin(1 ... 3))
    assertFailure(expectedMessage: #"failed - expect "4" to be within "1...3""#)

    expect(4, "count").to(beWithin(1 ... 3))
    assertFailure(expectedMessage: #"failed - expect "count" ("4") to be within "1...3""#)

    expect(2).toNot(beWithin(1 ..< 3))
    assertFailure(expectedMessage: #"failed - expect "2" to not be within "1..<3""#)

    expect(nil as Int?).to(beWithin(1 ... 3))
    assertFailure(expectedMessage: #"failed - expect "nil" to be within "1...3""#)
  }

  func test_beBetween() {
    expect(4).to(beBetween(3, and: 1))
    assertFailure(expectedMessage: #"failed - expect "4" to be within "1...3""#)

    expect(3.0, "shown").to(beBetween(2.0, and: 1.0, within: 0.5))
    assertFailure(expectedMessage: #"failed - expect "shown" ("3.0") to be within "0.5...2.5""#)
  }
}
