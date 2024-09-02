//
//  Data+DecodingTests.swift
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

import ChouTi
import ChouTiTest

class Data_DecodingTests: XCTestCase {

  func test_string() {
    do {
      let data = "Hello, World!".data(using: .utf8)! // swiftlint:disable:this force_unwrapping non_optional_string_data_conversion
      let string = data.string(encoding: .utf8)
      expect(string) == "Hello, World!"
    }

    do {
      let data = "Hello, World!".data(using: .utf16)! // swiftlint:disable:this force_unwrapping
      let string = data.string(encoding: .utf16)
      expect(string) == "Hello, World!"
    }

    // invalid encoding
    do {
      let data = "Hello, World!".data(using: .utf32)! // swiftlint:disable:this force_unwrapping
      let string = data.string(encoding: .utf8)
      expect(string) == nil
    }
  }

  func test_utf8String() {
    do {
      let data = "Hello, World!".data(using: .utf8)! // swiftlint:disable:this force_unwrapping non_optional_string_data_conversion
      let string = data.utf8String()
      expect(string) == "Hello, World!"
    }

    do {
      let data = "こんにちは、世界！".data(using: .utf8)! // swiftlint:disable:this force_unwrapping non_optional_string_data_conversion
      let string = data.utf8String()
      expect(string) == "こんにちは、世界！"
    }

    do {
      let data = "Hello, World!".data(using: .ascii)! // swiftlint:disable:this force_unwrapping
      let string = data.utf8String()
      expect(string) == "Hello, World!"
    }

    do {
      let data = "Hello, World!".data(using: .utf16)! // swiftlint:disable:this force_unwrapping
      let string = data.utf8String()
      expect(string) == "\u{fffd}\u{fffd}H\0e\0l\0l\0o\0,\0 \0W\0o\0r\0l\0d\0!\0"
    }

    do {
      let data = "你好，世界".data(using: .utf16)! // swiftlint:disable:this force_unwrapping
      let string = data.utf8String()
      expect(string) == "\u{fffd}\u{fffd}`O}Y\u{c}\u{fffd}\u{16}NLu"
    }

    do {
      let data = "你好，世界".data(using: .unicode)! // swiftlint:disable:this force_unwrapping
      let string = data.utf8String()
      expect(string) == "\u{fffd}\u{fffd}`O}Y\u{c}\u{fffd}\u{16}NLu"
    }
  }
}
