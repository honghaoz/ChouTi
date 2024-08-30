//
//  MachTimeId+IntervalTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/19/24.
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

final class MachTimeId_IntervalTests: XCTestCase {

  func testMachTimeInterval() {
    let start: UInt64 = 1000000
    let end: UInt64 = 2000000
    let interval = machTimeInterval(from: start, to: end)
    expect(interval).to(beGreaterThan(0))
  }

  func testMachTimeIdIntervalSince() {
    let start: MachTimeId = 1000000
    let end: MachTimeId = 2000000
    let interval = end.interval(since: start)
    expect(interval).to(beGreaterThan(0))
  }

  func testMachTimeIdIntervalWithMachAbsoluteTime() {
    let start = MachTimeId.id()
    // Simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }
    let end = MachTimeId.id()
    let interval = end.interval(since: start)

    expect(interval).to(beGreaterThan(0))
  }

  func testMachTimeIntervalWithMachAbsoluteTime() {
    let start = mach_absolute_time()
    // Simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }
    let end = mach_absolute_time()
    let interval = machTimeInterval(from: start, to: end)

    expect(interval).to(beGreaterThan(0))
  }
}
