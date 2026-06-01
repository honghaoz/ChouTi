//
//  MeasureTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/12/25.
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

import XCTest
import ChouTiTest

class MeasureTests: XCTestCase {

  private enum TestError: Error {
    case expectedFailure
  }

  func test_measure_runsBlockDefaultOnce() {
    var count = 0

    let elapsedTime = ChouTiTest.measure {
      count += 1
    }

    expect(count) == 1
    expect(elapsedTime) >= 0
  }

  func test_measure_runsBlockForRepeatCount() {
    let repeatCount = 5
    var iterations: [Int] = []

    let elapsedTime = ChouTiTest.measure(repeat: repeatCount) {
      iterations.append(iterations.count)
    }

    expect(iterations) == Array(0 ..< repeatCount)
    expect(elapsedTime) >= 0
  }

  func test_measure_withZeroRepeat_doesNotRunBlock() {
    var count = 0

    let elapsedTime = ChouTiTest.measure(repeat: 0) {
      count += 1
    }

    expect(count) == 0
    expect(elapsedTime) >= 0
  }

  func test_measure_throwing_runsBlockForRepeatCount() throws {
    let repeatCount = 5
    var count = 0
    func doWork() throws {
      count += 1
    }

    let elapsedTime = try ChouTiTest.measure(repeat: repeatCount) {
      try doWork()
    }

    expect(count) == repeatCount
    expect(elapsedTime) >= 0
  }

  func test_measure_throwing_rethrowsErrorAndStopsRunningBlock() {
    var count = 0

    do {
      _ = try ChouTiTest.measure(repeat: 5) {
        count += 1
        if count == 3 {
          throw TestError.expectedFailure
        }
      }
      fail("Expected measure to rethrow the block error.")
    } catch TestError.expectedFailure {
      expect(count) == 3
    } catch {
      fail("Expected TestError.expectedFailure, got \(error).")
    }
  }

  func test_measure_async_runsBlockForRepeatCount() async {
    let repeatCount = 5
    var count = 0

    let elapsedTime = await ChouTiTest.measure(repeat: repeatCount) {
      count += 1
      await Task.yield()
    }

    expect(count) == repeatCount
    expect(elapsedTime) >= 0
  }

  func test_measure_async_rethrowsErrorAndStopsRunningBlock() async {
    var count = 0

    do {
      _ = try await ChouTiTest.measure(repeat: 5) {
        count += 1
        if count == 3 {
          throw TestError.expectedFailure
        }
        await Task.yield()
      }
      fail("Expected measure to rethrow the block error.")
    } catch TestError.expectedFailure {
      expect(count) == 3
    } catch {
      fail("Expected TestError.expectedFailure, got \(error).")
    }
  }
}
