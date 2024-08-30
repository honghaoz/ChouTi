//
//  ClosureTypesTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/19/24.
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

final class TypeAliasTests: XCTestCase {

  // Test BlockVoid
  func testBlockVoid() {
    let block: BlockVoid = {}
    block()
  }

  // Test BlockThrowsVoid
  func testBlockThrowsVoid() {
    let block: BlockThrowsVoid = {}
    expect(try block()).toNot(throwAnError())
  }

  // Test BlockAsyncVoid
  func testBlockAsyncVoid() async {
    let block: BlockAsyncVoid = {}
    await block()
  }

  // Test BlockAsyncThrowsVoid
  func testBlockAsyncThrowsVoid() async {
    let block: BlockAsyncThrowsVoid = {
      try await Task.sleep(nanoseconds: 1)
    }
    do {
      try await block()
    } catch {}
  }

  // Test BlockBool
  func testBlockBool() {
    var result = false
    let block: BlockBool = { parameter in
      result = parameter
    }
    block(true)
    expect(result) == true
  }

  // Test BlockThrowsBool
  func testBlockThrowsBool() {
    var result = false
    let block: BlockThrowsBool = { parameter in
      result = parameter
    }
    expect(try block(true)).toNot(throwAnError())
    expect(result) == true
  }
}
