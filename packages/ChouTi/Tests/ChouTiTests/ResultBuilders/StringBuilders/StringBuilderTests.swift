//
//  StringBuilderTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/1/24.
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

class StringBuilderTests: XCTestCase {

  func test() {
    let string = String {
      "Hello"
      "World"
    }
    expect(string) == "Hello\nWorld"
  }

  func test_empty() {
    let string = String {}
    expect(string) == ""
  }

  func test_separator() {
    let string = String(separator: ", ") {
      "Hello"
      "World"
    }
    expect(string) == "Hello, World"
  }

  func test_optional() {
    let string = String {
      "Hello"
      nil
      "World"
    } as String?
    expect(string) == "Hello\nWorld"
  }

  func test_optional_empty() {
    let string = String {} as String?
    expect(string) == nil
  }

  func test_emptyOptional() {
    let string = String {
      nil
    } as String?
    expect(string) == nil
  }

  func test_optional_separator() {
    let string = String(separator: ", ") {
      nil
      "Hello"
      nil
      "World"
    } as String?
    expect(string) == "Hello, World"
  }
}
