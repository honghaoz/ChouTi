//
//  Optional+AssertTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/5/21.
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

class Optional_AssertTests: XCTestCase {

  func test_valid() {
    let number: Int? = 2
    expect(number.assert() ?? 1) == 2
  }

  func test_nil() {
    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Unexpected nil value"
      }

      let nilNumber: Int? = nil
      expect(nilNumber.assert() ?? 1) == 1

      Assert.resetTestAssertionFailureHandler()
    }

    do {
      // with metadata
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Unexpected nil value"
        expect(metadata) == ["key": "value"]
      }

      let nilNumber: Int? = nil
      expect(nilNumber.assert(metadata: ["key": "value"]) ?? 1) == 1

      Assert.resetTestAssertionFailureHandler()
    }
  }
}
