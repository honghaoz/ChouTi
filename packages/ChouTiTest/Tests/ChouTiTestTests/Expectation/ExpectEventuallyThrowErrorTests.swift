//
//  ExpectEventuallyThrowErrorTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/11/26.
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

class ExpectEventuallyThrowErrorTests: XCTestCase {

  private enum TestError: Error {
    case error1
    case error2
  }

  func test_toEventually_throwAnError() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count >= 3 {
        throw TestError.error1
      }
      return true
    }

    expect(try calculate()).toEventually(throwAnError())
  }

  func test_toEventuallyNot_throwAnError() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count <= 3 {
        throw TestError.error1
      }
      return true
    }

    expect(try calculate()).toEventuallyNot(throwAnError())
  }

  func test_toEventually_throwError() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count >= 3 {
        throw TestError.error1
      }
      return true
    }

    expect(try calculate()).toEventually(throwError(TestError.error1))
  }

  func test_toEventually_throwError_withWrongErrorInitially() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count < 3 {
        throw TestError.error2 // wrong error initially
      } else if count >= 3 {
        throw TestError.error1 // correct error eventually
      }
      return true
    }

    expect(try calculate()).toEventually(throwError(TestError.error1))
  }

  func test_toEventuallyNot_throwError() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count <= 3 {
        throw TestError.error1
      }
      return true
    }

    expect(try calculate()).toEventuallyNot(throwError(TestError.error1))
  }

  func test_toEventuallyNot_throwError_throwDifferentError() {
    func calculate() throws -> Bool {
      throw TestError.error2 // throw a different error, should pass immediately
    }

    expect(try calculate()).toEventuallyNot(throwError(TestError.error1))
  }

  func test_toEventually_throwErrorOfType() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count >= 3 {
        throw TestError.error1
      }
      return true
    }

    expect(try calculate()).toEventually(throwErrorOfType(TestError.self))
  }

  func test_toEventually_throwErrorOfType_withWrongTypeInitially() {
    enum OtherError: Error {
      case other
    }

    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count < 3 {
        throw OtherError.other // wrong error type initially
      } else if count >= 3 {
        throw TestError.error1 // correct error type eventually
      }
      return true
    }

    expect(try calculate()).toEventually(throwErrorOfType(TestError.self))
  }

  func test_toEventuallyNot_throwErrorOfType() {
    var count = 0
    func calculate() throws -> Bool {
      count += 1
      if count <= 3 {
        throw TestError.error1
      }
      return true
    }

    expect(try calculate()).toEventuallyNot(throwErrorOfType(TestError.self))
  }

  func test_toEventuallyNot_throwErrorOfType_throwDifferentType() {
    enum OtherError: Error {
      case other
    }

    func calculate() throws -> Bool {
      throw OtherError.other // throw a different error type, should pass immediately
    }

    expect(try calculate()).toEventuallyNot(throwErrorOfType(TestError.self))
  }
}
