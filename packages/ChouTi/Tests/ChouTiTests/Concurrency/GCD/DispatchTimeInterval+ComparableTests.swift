//
//  DispatchTimeInterval+ComparableTests.swift
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
