//
//  DeallocationNotifiableTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/3/23.
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

import Foundation

import ChouTiTest

import ChouTi

class DeallocationNotifiableTests: XCTestCase {

  func test_addDeallocateBlock() {
    var object: TestObject? = TestObject()
    var called: Bool = false
    object?.onDeallocate {
      called = true
    }
    object = nil

    expect(called) == true
  }

  func test_add_multiple_deallocateBlock() {
    var object: TestObject? = TestObject()

    var called1: Bool = false
    var called2: Bool = false
    object?.onDeallocate {
      called1 = true
    }
    object?.onDeallocate {
      called2 = true
    }

    object = nil

    expect(called1) == true
    expect(called2) == true
  }

  func test_remove_deallocateBlock() {
    var object: TestObject? = TestObject()
    var called: Bool = false
    let token = object?.onDeallocate {
      called = true
    }

    token?.cancel()

    object = nil
    expect(called) == false
  }
}

class TestObject: DeallocationNotifiable {}
