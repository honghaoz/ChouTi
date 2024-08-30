//
//  LogMessageTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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

@testable import ChouTi

class LogMessageTests: XCTestCase {

  func testSimpleString() {
    do {
      let message: LogMessage = "test"
      expect(message.materializedString()) == "test"
      expect(message.materializedString()) == "test"
    }

    do {
      let message = LogMessage("test")
      expect(message.materializedString()) == "test"
    }
  }

  func testNumberInterpolation() {
    let message: LogMessage = "test: \(123)"
    expect(message.materializedString()) == "test: 123"
  }

  func testStringInterpolation() {
    let message: LogMessage = "test: \("hey there")"
    expect(message.materializedString()) == "test: hey there"
  }

  func testClassInterpolation() {
    class Foo {
      let bar: [String] = ["yes"]
    }

    let foo = Foo()
    let message: LogMessage = "test: \(foo)"
    let string = "test: \(foo)"
    expect(message.materializedString()) == string
    expect(message.materializedString()) == string
  }

  func testStructInterpolation() {
    struct Foo {
      let bar: [String] = ["yes"]
    }

    let foo = Foo()
    let message: LogMessage = "test: \(foo)"
    let string = "test: \(foo)"
    expect(message.materializedString()) == string
  }

  func testPrivacyInterpolation() {
    struct Foo {
      let bar: [String] = ["yes"]
    }

    let foo = Foo()
    let message: LogMessage = "test: \(foo, privacy: .private), \(foo, privacy: .public)"
    expect(message.materializedString()) == #"test: <private>, Foo(bar: ["yes"])"#
  }

  func testDefault() {
    let nilValue: Int? = nil
    let validValue: Int? = 1
    let message: LogMessage = "test: \(validValue, default: "default"), test: \(nilValue, default: "default")"
    expect(message.materializedString()) == "test: 1, test: default"
  }
}
