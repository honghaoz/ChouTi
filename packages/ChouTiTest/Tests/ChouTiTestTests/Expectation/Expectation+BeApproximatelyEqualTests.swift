//
//  Expectation+BeApproximatelyEqualTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/18/26.
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

import Foundation

import ChouTiTest
import XCTest

class Expectation_BeApproximatelyEqualTests: XCTestCase {

  func test_beApproximatelyEqual() {
    expect(1.0).to(beApproximatelyEqual(to: 1.0, within: 0))
    expect(1.25).to(beApproximatelyEqual(to: 1.0, within: 0.5))
    expect(1.5).to(beApproximatelyEqual(to: 1.0, within: 0.5))
    expect(1.75).toNot(beApproximatelyEqual(to: 1.0, within: 0.5))
    expect(Double.infinity).to(beApproximatelyEqual(to: .infinity, within: 0))
    expect(Double.nan).toNot(beApproximatelyEqual(to: .nan, within: 1))
    expect(beApproximatelyEqual(to: 1.0, within: 0.5).description) == #"be approximately equal to "1.0 ± 0.5""#
  }

  func test_beApproximatelyEqual_array() {
    // values and tolerance are exact in binary, so the tolerance boundary is exact too
    expect([1.0, 2.0]).to(beApproximatelyEqual(to: [1.0, 2.0], within: 0))
    expect([1.25, 1.75]).to(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    expect([1.5, 1.5]).to(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    expect([1.75, 2.0]).toNot(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    expect([1.0, 1.25]).toNot(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    expect([2.0, 1.0]).toNot(beApproximatelyEqual(to: [1.0, 2.0], within: 0))
    expect([Double]()).to(beApproximatelyEqual(to: [], within: 0.5))
    expect(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5).description) == #"be approximately equal to "[1.0, 2.0] ± 0.5""#
  }

  func test_beApproximatelyEqual_array_differentCounts() {
    expect([1.0]).toNot(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    expect([1.0, 2.0, 3.0]).toNot(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    expect([Double]()).toNot(beApproximatelyEqual(to: [1.0], within: 0.5))
  }

  func test_beApproximatelyEqual_array_infinityAndNaN() {
    expect([Double.infinity]).to(beApproximatelyEqual(to: [.infinity], within: 0))
    expect([Double.nan]).toNot(beApproximatelyEqual(to: [.infinity], within: 1))
    expect([Double.nan]).toNot(beApproximatelyEqual(to: [.nan], within: 1))
  }

  func test_beApproximatelyEqual_array_optionalAndEventually() {
    let value: [Double]? = [1.25]
    let nilValue: [Double]? = nil

    expect(value).to(beApproximatelyEqual(to: [1.0], within: 0.5))
    expect(nilValue).toNot(beApproximatelyEqual(to: [1.0], within: 0.5))
    expect([1.25]).toEventually(beApproximatelyEqual(to: [1.0], within: 0.5))
  }
}

class Expectation_BeApproximatelyEqualFailureMessageTests: FailureCapturingTestCase {

  func test_beApproximatelyEqual_array() {
    expect([1.0, 3.0]).to(beApproximatelyEqual(to: [1.0, 2.0], within: 0.5))
    assertFailure(expectedMessage: #"failed - expect "[1.0, 3.0]" to be approximately equal to "[1.0, 2.0] ± 0.5""#)
  }
}
