//
//  PerformanceMeasurerTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/20/24.
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

final class PerformanceMeasurerTests: XCTestCase {

  // MARK: - Instance

  func testInstanceMeasurement() {
    let measurer = PerformanceMeasurer()

    measurer.start()

    // simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }

    let consoleOutput = captureConsoleOutput {
      let elapsedTime = measurer.end()
      expect(elapsedTime).to(beGreaterThan(0))
    }

    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testInstanceUnbalancedEndCall() {
    let measurer = PerformanceMeasurer()

    let consoleOutput = captureConsoleOutput {
      let elapsedTime = measurer.end()
      expect(elapsedTime) == 0
    }

    if !isCommandLine {
      expect(consoleOutput.contains("Unbalanced end() call."), consoleOutput) == true
    }
  }

  func testInstanceMeasurement_printWithoutMeasurement() {
    let measurer = PerformanceMeasurer()

    measurer.start()

    // simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }

    let consoleOutput = captureConsoleOutput {
      measurer.print(tag: "TestTag")
    }

    if !isCommandLine {
      expect(consoleOutput.contains("No elapsed time yet"), consoleOutput) == true
    }
  }

  func testInstanceMeasurement_print() {
    let measurer = PerformanceMeasurer()

    measurer.start()

    // simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }

    let elapsedTime = measurer.end()
    expect(elapsedTime).to(beGreaterThan(0))

    do {
      let consoleOutput = captureConsoleOutput {
        measurer.print(tag: "TestTag")
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = captureConsoleOutput {
        measurer.print(tag: "TestTag", tagLength: 12)
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag     ] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = captureConsoleOutput {
        measurer.print(tag: "TestTag", tagLength: 12, tagPad: "*")
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag*****] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = captureConsoleOutput {
        measurer.print(tag: "TestTag", tagLength: 12, tagPad: "*", useScientificNumber: true)
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag*****] Elapsed time: "), consoleOutput) == true
        expect(consoleOutput.contains("e-"), consoleOutput) == true
      }
    }
  }

  // MARK: - Start/End Calls

  func test_start_end() {
    PerformanceMeasurer.start()

    // simulate some work
    for _ in 0 ..< 10 {
      _ = UUID().uuidString
    }

    let consoleOutput = captureConsoleOutput {
      let timeElapsed = PerformanceMeasurer.end()
      expect(timeElapsed).to(beGreaterThan(0))
    }

    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testUnbalancedEndCall() {
    let consoleOutput = captureConsoleOutput {
      PerformanceMeasurer.end()
    }
    if !isCommandLine {
      expect(consoleOutput.contains("Unbalanced end() call. Call start() first."), consoleOutput) == true
    }
  }

  // MARK: - Blocks

  func testMeasureBlock() {
    let consoleOutput = captureConsoleOutput {
      let timeElapsed = PerformanceMeasurer.measure {
        // simulate some work
        for _ in 0 ..< 10 {
          _ = UUID().uuidString
        }
      }
      expect(timeElapsed).to(beGreaterThan(0))
    }

    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testMeasureBlockReturnValue() {
    let consoleOutput = captureConsoleOutput {
      let (result, timeElapsed) = PerformanceMeasurer.measure {
        // simulate some work
        for _ in 0 ..< 10 {
          _ = UUID().uuidString
        }
        return 100
      }
      expect(result) == 100
      expect(timeElapsed).to(beGreaterThan(0))
    }

    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testMeasureBlockReturnValueThrow() {
    enum Error: Swift.Error {
      case foo
    }

    func throwFunction() throws -> Int {
      throw Error.foo
    }

    let consoleOutput = captureConsoleOutput {
      let (_, timeElapsed) = try PerformanceMeasurer.measure {
        // simulate some work
        for _ in 0 ..< 10 {
          _ = UUID().uuidString
        }
        return try throwFunction()
      }
      expect(timeElapsed).to(beGreaterThan(0))
    }

    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  // MARK: - Repeat

  func testMeasureRepeat() throws {
    func work() throws -> Int {
      // simulate some work
      for _ in 0 ..< 10 {
        _ = UUID().uuidString
      }

      return 100
    }

    let consoleOutput = captureConsoleOutput {
      let timeElapsed = try PerformanceMeasurer.measure(repeatCount: 5) {
        _ = try work()
      }
      expect(timeElapsed).to(beGreaterThan(0))
    }
    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testMeasureRepeatWithPrint() {
    func work() throws -> Int {
      // simulate some work
      for _ in 0 ..< 10 {
        _ = UUID().uuidString
      }

      return 100
    }

    do {
      let consoleOutput = captureConsoleOutput {
        let timeElapsed = try PerformanceMeasurer.measure(tag: "TestTag", repeatCount: 5) {
          _ = try work()
        }
        expect(timeElapsed).to(beGreaterThan(0))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = captureConsoleOutput {
        let timeElapsed = try PerformanceMeasurer.measure(tag: "TestTag", tagLength: 12, repeatCount: 5) {
          _ = try work()
        }
        expect(timeElapsed).to(beGreaterThan(0))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag     ] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = captureConsoleOutput {
        let timeElapsed = try PerformanceMeasurer.measure(tag: "TestTag", tagLength: 12, tagPad: "*", repeatCount: 5) {
          _ = try work()
        }
        expect(timeElapsed).to(beGreaterThan(0))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag*****] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = captureConsoleOutput {
        let timeElapsed = try PerformanceMeasurer.measure(tag: "TestTag", tagLength: 12, tagPad: "*", useScientificNumber: true, repeatCount: 5) {
          _ = try work()
        }
        expect(timeElapsed).to(beGreaterThan(0))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag*****] Elapsed time: "), consoleOutput) == true
        expect(consoleOutput.contains("e-"), consoleOutput) == true
      }
    }
  }

  // MARK: - Async Repeat

  func testMeasureAsyncRepeat() async throws {
    func work() async throws -> Int {
      // simulate some async work
      try await Task.sleep(nanoseconds: 10000000) // 10 milliseconds
      return 100
    }

    let consoleOutput = await captureConsoleOutput {
      let timeElapsed = try await PerformanceMeasurer.measure(repeatCount: 5) {
        _ = try await work()
      }
      expect(timeElapsed).to(beGreaterThan(0.05)) // At least 50ms (5 * 10ms)
    }
    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testMeasureAsyncRepeatWithPrint() async throws {
    func work() async throws -> Int {
      // simulate some async work
      try await Task.sleep(nanoseconds: 10000000) // 10 milliseconds
      return 100
    }

    do {
      let consoleOutput = await captureConsoleOutput {
        let timeElapsed = try await PerformanceMeasurer.measure(tag: "TestTag", repeatCount: 5) {
          _ = try await work()
        }
        expect(timeElapsed).to(beGreaterThan(0.05))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = await captureConsoleOutput {
        let timeElapsed = try await PerformanceMeasurer.measure(tag: "TestTag", tagLength: 12, repeatCount: 5) {
          _ = try await work()
        }
        expect(timeElapsed).to(beGreaterThan(0.05))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag     ] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = await captureConsoleOutput {
        let timeElapsed = try await PerformanceMeasurer.measure(tag: "TestTag", tagLength: 12, tagPad: "*", repeatCount: 5) {
          _ = try await work()
        }
        expect(timeElapsed).to(beGreaterThan(0.05))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag*****] Elapsed time: "), consoleOutput) == true
      }
    }

    do {
      let consoleOutput = await captureConsoleOutput {
        let timeElapsed = try await PerformanceMeasurer.measure(tag: "TestTag", tagLength: 12, tagPad: "*", useScientificNumber: true, repeatCount: 5) {
          _ = try await work()
        }
        expect(timeElapsed).to(beGreaterThan(0.05))
      }
      if !isCommandLine {
        expect(consoleOutput.contains("[TestTag*****] Elapsed time: "), consoleOutput) == true
        expect(consoleOutput.contains("e-"), consoleOutput) == true
      }
    }
  }

  private var isCommandLine: Bool {
    #if TEST
    // TEST flag is set via `swift test -Xswiftc -DTEST`
    return true
    #else
    return false
    #endif
  }

  private func captureConsoleOutput(_ block: () throws -> Void) -> String {
    let pipe = Pipe()
    let originalStandardOutput = dup(fileno(stdout))
    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

    try? block()

    pipe.fileHandleForWriting.closeFile()
    dup2(originalStandardOutput, fileno(stdout))
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    pipe.fileHandleForReading.closeFile()

    return String(decoding: data, as: UTF8.self)
  }

  // Helper function to capture console output in async context
  private func captureConsoleOutput(_ block: () async throws -> Void) async -> String {
    let pipe = Pipe()
    let originalStandardOutput = dup(fileno(stdout))
    dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stdout))

    do {
      try await block()
    } catch {
      print("Error occurred: \(error)")
    }

    pipe.fileHandleForWriting.closeFile()
    dup2(originalStandardOutput, fileno(stdout))
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    pipe.fileHandleForReading.closeFile()

    return String(decoding: data, as: UTF8.self)
  }
}
