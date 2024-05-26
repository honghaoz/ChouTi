//
//  PerformanceMeasurerTests.swift
//
//  Created by Honghao Zhang on 5/20/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
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
      XCTAssertGreaterThan(elapsedTime, 0)
    }

    expect(consoleOutput, consoleOutput).to(beEmpty())
  }

  func testInstanceUnbalancedEndCall() {
    let measurer = PerformanceMeasurer()

    let consoleOutput = captureConsoleOutput {
      let elapsedTime = measurer.end()
      XCTAssertEqual(elapsedTime, 0)
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
    XCTAssertGreaterThan(elapsedTime, 0)

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
      XCTAssertGreaterThan(timeElapsed, 0)
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
      XCTAssertGreaterThan(timeElapsed, 0)
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
      XCTAssertGreaterThan(timeElapsed, 0)
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
      XCTAssertGreaterThan(timeElapsed, 0)
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
      XCTAssertGreaterThan(timeElapsed, 0)
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
        XCTAssertGreaterThan(timeElapsed, 0)
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
        XCTAssertGreaterThan(timeElapsed, 0)
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
        XCTAssertGreaterThan(timeElapsed, 0)
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
        XCTAssertGreaterThan(timeElapsed, 0)
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
}
