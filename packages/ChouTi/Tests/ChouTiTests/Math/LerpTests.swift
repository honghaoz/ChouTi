//
//  LerpTests.swift
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

class LerpTests: XCTestCase {

  func testLerp() {
    // common
    XCTAssertEqual(lerp(start: 0, end: 100, t: 0.5), 50)
    XCTAssertEqual(lerp(start: 10.0, end: 20.0, t: 0.1), 11.0)
    XCTAssertEqual(lerp(start: 10.0, end: 10.0, t: 0.1), 10.0)
    // clamps
    XCTAssertEqual(lerp(start: 10.0, end: 20.0, t: -1.1), 10)
    XCTAssertEqual(lerp(start: 10.0, end: 20.0, t: 1.1), 20)
    // revered
    XCTAssertEqual(lerp(start: 20.0, end: 10.0, t: 0.1), 19.0)

    // common
    XCTAssertEqual(0.lerp(end: 100, t: 0.5), 50)
    XCTAssertEqual(10.0.lerp(end: 20.0, t: 0.1), 11.0)
    XCTAssertEqual(10.lerp(end: 10.0, t: 0.1), 10.0)
    // clamps
    XCTAssertEqual(10.lerp(end: 20.0, t: -1.1), 10)
    XCTAssertEqual(10.lerp(end: 20.0, t: 1.1), 20)
    // revered
    XCTAssertEqual(20.lerp(end: 10.0, t: 0.1), 19.0)
  }
}
