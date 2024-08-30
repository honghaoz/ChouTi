//
//  Thread+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/5/21.
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

class Thread_ExtensionsTests: XCTestCase {

  func test_isRunningXCTest() {
    expect(Thread.isRunningXCTest) == true
  }

  func test_isRunningXCTest_withNonStringKey() {
    let mockThreadDictionary: NSDictionary = [
      123: "Some value", // Non-string key
    ]

    expect(Thread._isRunningXCTest(threadDictionary: mockThreadDictionary)) == false
  }

  func test_callStackSymbolsString() {
    let callStackSymbolsString = Thread.callStackSymbolsString()
    expect(callStackSymbolsString.isEmpty) == false
  }
}
