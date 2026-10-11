//
//  FloatingPoint+ApproximateEqualityTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/3/21.
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

class FloatingPoint_ApproximateEqualityTests: XCTestCase {

  func test() {
    expect(0.1.isApproximatelyEqual(to: 0.1, absoluteTolerance: 1e-5)) == true
    expect(0.1.isApproximatelyEqual(to: 0.1, absoluteTolerance: 1e-10)) == true
    expect(0.1.isApproximatelyEqual(to: 0.101, absoluteTolerance: 1e-5)) == false
    expect(0.1.isApproximatelyEqual(to: 0.101, absoluteTolerance: 1e-1)) == true
  }

  func test_infinity() {
    expect(that: Double.infinity.isApproximatelyEqual(to: .infinity, absoluteTolerance: 0))
    expect(that: Double.infinity.isApproximatelyEqual(to: .infinity, absoluteTolerance: 1))
    expect(that: (-Double.infinity).isApproximatelyEqual(to: -.infinity, absoluteTolerance: 0))
    expect(that: Float.infinity.isApproximatelyEqual(to: .infinity, absoluteTolerance: 0))

    expect(Double.infinity.isApproximatelyEqual(to: -.infinity, absoluteTolerance: 1)) == false
    expect(Double.infinity.isApproximatelyEqual(to: .greatestFiniteMagnitude, absoluteTolerance: 1)) == false
    expect(1.0.isApproximatelyEqual(to: .infinity, absoluteTolerance: 1)) == false
  }

  func test_nan() {
    expect(Double.nan.isApproximatelyEqual(to: .nan, absoluteTolerance: 1)) == false
    expect(Double.nan.isApproximatelyEqual(to: 0, absoluteTolerance: 1)) == false
    expect(0.0.isApproximatelyEqual(to: .nan, absoluteTolerance: 1)) == false
  }
}
