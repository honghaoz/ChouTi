//
//  BoxTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2/27/23.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

class BoxTests: XCTestCase {

  func testBoxContainsArrayOfStrings() {
    let box = ["1", "2"].wrapInBox()
    expect(box.value) == ["1", "2"]
  }

  // Test when box is a constant in a struct
  struct TestStruct {
    let aBox: Box<Int>!
  }

  func testBoxInStruct() {
    let value = TestStruct(aBox: Box<Int>(1))

    expect(value.aBox.value, "initial value of the box") == 1

    value.aBox.value = 2
    expect(value.aBox.value, "updated value of the box") == 2
  }
}
