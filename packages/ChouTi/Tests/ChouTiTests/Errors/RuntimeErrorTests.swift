//
//  RuntimeErrorTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/26/24.
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

class RuntimeErrorTests: XCTestCase {

  func test_runtimeError() {
    do {
      let error = RuntimeError.empty
      expect(error.description) == "<empty>"
    }

    do {
      let error = RuntimeError.reason("custom error")
      expect(error.description) == "custom error"
    }

    do {
      let error = RuntimeError.error(NSError(domain: "com.chouti.error", code: 1, userInfo: nil))
      expect(error.description) == #"Error Domain=com.chouti.error Code=1 "(null)""#
    }
  }

  func test_Equatable() {
    expect(RuntimeError.empty) == RuntimeError.empty
    expect(RuntimeError.empty) != RuntimeError.reason("custom error")
    expect(RuntimeError.reason("custom error")) == RuntimeError.reason("custom error")
    expect(RuntimeError.error(NSError(domain: "com.chouti.error", code: 1, userInfo: nil))) == RuntimeError.error(NSError(domain: "com.chouti.error", code: 1, userInfo: nil))
  }
}
