//
//  OptionalExpectThrowErrorTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/24/24.
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
import XCTest

import Foundation

class OptionalExpectThrowErrorTests: XCTestCase {

  func testThrowError() {
    enum FooError: Swift.Error, Equatable {
      case error1
      case error2
    }

    func noThrowErrorFunc() throws -> Int? {
      1
    }

    func throwError1Func() throws -> Int? {
      throw FooError.error1
    }

    expect(try throwError1Func()).to(throwError(FooError.error1))
    expect(try throwError1Func()).toNot(throwError(FooError.error2))

    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error1))
    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error2))
  }

  func testThrowErrorType() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum FooError2: Swift.Error {
      case error1
      case error2
    }

    func noThrowErrorFunc() throws -> Int? {
      1
    }

    func throwError1Func() throws -> Int? {
      throw FooError.error1
    }

    expect(try throwError1Func()).to(throwErrorOfType(FooError.self))
    expect(try throwError1Func()).toNot(throwErrorOfType(FooError2.self))

    expect(try throwError1Func()).toNot(throwErrorOfType(FooError2.self))
    expect(try noThrowErrorFunc()).toNot(throwErrorOfType(FooError.self))
  }
}
