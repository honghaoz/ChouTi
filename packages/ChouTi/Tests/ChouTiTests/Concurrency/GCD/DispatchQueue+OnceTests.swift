//
//  DispatchQueue+OnceTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/16/21.
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

final class DispatchQueue_OnceTests: XCTestCase {

  func test_once_block() {
    var callCount = 0
    func execute() {
      DispatchQueue.once {
        callCount += 1
      }
    }

    expect(callCount) == 0
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
  }

  func test_once_block_withToken() {
    var callCount = 0
    func execute() {
      DispatchQueue.once(token: "key") {
        callCount += 1
      }
    }

    expect(callCount) == 0
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1

    DispatchQueue.once(token: "key2") {
      callCount += 1
    }
    expect(callCount) == 2
  }

  func test_once_bool() {
    var callCount = 0
    func execute() {
      guard DispatchQueue.once() else {
        return
      }
      callCount += 1
    }

    expect(callCount) == 0
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
  }

  func test_assertOnce() {
    func execute() {
      assertOnce()
    }

    execute()

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "should only call once, token: ChouTiTests/DispatchQueue+OnceTests.swift:96:17"
    }
    execute()
    Assert.resetTestAssertionFailureHandler()
  }
}
