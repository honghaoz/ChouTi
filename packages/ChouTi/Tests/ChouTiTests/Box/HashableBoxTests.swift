//
//  HashableBoxTests.swift
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

class HashableBoxTests: XCTestCase {

  func testHashableBox_Int() {
    let box = HashableBox(key: 1, "abc")
    let box2 = HashableBox(key: 1, "def")
    expect(box) == box2

    expect(box.hashValue) == box.hashValue

    expect(box.key) == 1
    expect(box.value) == "abc"
  }

  func testHashableBox_String() {
    let box = HashableBox(key: "key2", "abc")
    let box2 = HashableBox(key: "key2", "def")
    expect(box) == box2

    expect(box.key) == "key2"
    expect(box.value) == "abc"
  }

  func test_key() {
    let box = HashableBox.key(1, "abc")
    let box2 = HashableBox.key(1, "def")
    expect(box) == box2

    expect(box.key) == 1
    expect(box.value) == "abc"
  }

  func test_unique_MachTimeId() {
    let box = HashableBox<MachTimeId, String>.unique("abc")
    let box2 = HashableBox<MachTimeId, String>.unique("def")
    expect(box) != box2
  }

  func test_unique_String() {
    let box = HashableBox<String, String>.unique("abc")
    let box2 = HashableBox<String, String>.unique("def")
    expect(box) != box2
  }

  func test_fixed_AnyHashable() {
    let box = HashableBox<AnyHashable, String>.fixed("abc")
    let box2 = HashableBox<AnyHashable, String>.fixed("def")
    expect(box) == box2
  }

  func test_unique_AnyHashable() {
    let box = HashableBox<AnyHashable, String>.unique("abc")
    let box2 = HashableBox<AnyHashable, String>.unique("def")
    expect(box) != box2
  }
}
