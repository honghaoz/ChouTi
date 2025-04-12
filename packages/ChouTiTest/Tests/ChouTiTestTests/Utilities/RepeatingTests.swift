//
//  RepeatingTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/30/24.
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

@testable import ChouTiTest
import XCTest

class RepeatingTests: XCTestCase {

  func testRepeating() {
    let expectation = XCTestExpectation()
    var count = 0
    repeating(interval: 0.01, timeout: 0.05, queue: .main) { _ in
      count += 1
      if count == 3 {
        expectation.fulfill()
        return true
      }
      return false
    }
    wait(for: [expectation], timeout: 0.1)
  }

  func testRepeating_invalidInterval() {
    let expectation = XCTestExpectation()
    expectation.isInverted = true

    repeating(interval: 0, timeout: 0.05, queue: .main) { _ in
      expectation.fulfill()
      return true
    }
    wait(for: [expectation], timeout: 0.1)
  }

  func testRepeating_invalidTimeout() {
    let expectation = XCTestExpectation()
    expectation.isInverted = true

    repeating(interval: 0.01, timeout: 0, queue: .main) { _ in
      expectation.fulfill()
      return true
    }
    wait(for: [expectation], timeout: 0.1)
  }
}
