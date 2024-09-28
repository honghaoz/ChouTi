//
//  ArrayBuilderTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/11/22.
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

class ArrayBuilderTests: XCTestCase {

  private var flag: Bool = false
  private var stringOrNil: String?

  override func setUp() {
    flag = false
    stringOrNil = nil
  }

  func test1() {
    flag = false
    stringOrNil = nil
    expect(makeArray()) == ["1", "2", "false", "item: 0", "item: 1", "iOS 16", "a", "b", "c"]
  }

  func test2() {
    flag = true
    stringOrNil = nil
    expect(makeArray()) == ["1", "2", "true", "item: 0", "item: 1", "iOS 16", "a", "b", "c"]
  }

  func test3() {
    flag = false
    stringOrNil = "apple"
    expect(makeArray()) == ["1", "2", "false", "item: 0", "item: 1", "apple", "iOS 16", "a", "b", "c"]
  }

  func test4() {
    flag = true
    stringOrNil = "apple"
    expect(makeArray()) == ["1", "2", "true", "item: 0", "item: 1", "apple", "iOS 16", "a", "b", "c"]
  }

  private func makeArray() -> [String] {
    Array {
      "1"
      "2"
      if flag {
        "true"
      } else {
        "false"
      }

      for i in 0 ..< 2 {
        "item: \(i)"
      }

      if let string = stringOrNil {
        string
      }

      if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
        "iOS 16"
      } else {
        "iOS 15"
      }

      ["a", "b", "c"]

      ()
    }
  }
}
