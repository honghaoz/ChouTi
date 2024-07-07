//
//  PerformanceMeasurer.swift
//
//  Created by Honghao Zhang on 12/12/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import QuartzCore

/// Performance measurer.
public final class PerformanceMeasurer {

  private var startTime: CFTimeInterval?
  private var elapsedTime: CFTimeInterval?

  /// Initialize a performance measurer.
  /// - Parameters:
  ///   - tag: The tag for the performance measurer.
  public init() {}

  /// Start the performance measurement.
  public func start() {
    startTime = CACurrentMediaTime()
  }

  /// End the performance measurement.
  /// - Returns: The elapsed time. Returns `0` if `start()` is not called.
  @discardableResult
  public func end() -> CFTimeInterval {
    guard let startTime else {
      logger.warning("Unbalanced end() call. Call start() first.")
      return 0
    }

    let elapsedTime = CACurrentMediaTime() - startTime
    self.elapsedTime = elapsedTime

    self.startTime = nil
    return elapsedTime
  }

  public func print(tag: String,
                    tagLength: Int? = nil,
                    tagPad: Character? = nil,
                    useScientificNumber: Bool = false)
  {
    guard let elapsedTime else {
      logger.warning("No elapsed time yet")
      return
    }

    var tag = tag
    if let tagLength {
      tag = tag.padding(toLength: max(tag.count, tagLength), withPad: tagPad.map { String($0) } ?? " ", startingAt: 0)
    }
    if useScientificNumber {
      // swiftlint:disable:next force_unwrapping
      Swift.print("[\(tag)] Elapsed time: \(PerformanceMeasurer.numberFormatter.string(for: elapsedTime)!)")
    } else {
      Swift.print("[\(tag)] Elapsed time: \(elapsedTime)")
    }
  }
}

// MARK: - Start/End Calls

public extension PerformanceMeasurer {

  /// The start time of the performance measurement.
  private static var startTime: CFTimeInterval?

  /// Start the performance measurement.
  ///
  /// Example:
  /// ```swift
  /// PerformanceMeasurer.start()
  ///
  /// // do your work...
  ///
  /// let elapsedTime = PerformanceMeasurer.end()
  /// print("elapsed time: \(elapsedTime)")
  /// ```
  static func start() {
    startTime = CACurrentMediaTime()
  }

  /// End the performance measurement.
  ///
  /// - Note: You must call `start()` before calling this method.
  ///
  /// - Returns: The elapsed time.
  @discardableResult
  static func end() -> CFTimeInterval {
    guard let startTime else {
      logger.warning("Unbalanced end() call. Call start() first.")
      return 0
    }
    let timeElapsed = CACurrentMediaTime() - startTime
    self.startTime = nil
    return timeElapsed
  }
}

// MARK: - Blocks

public extension PerformanceMeasurer {

  // From: https://www.objc.io/blog/2018/06/14/quick-performance-timing/

  /// Measure the execution time of the block.
  ///
  /// Example:
  /// ```swift
  /// let numbers = Array(1...10_000)
  /// let elapsedTime = PerformanceMeasurer.measure {
  ///   _ = numbers.concurrentMap { $0 * $0 }
  /// }
  /// print("elapsed time: \(elapsedTime)")
  /// ```
  ///
  /// - Parameters:
  ///   - block: The execution block to measure.
  /// - Returns: The elapsed duration.
  @discardableResult
  static func measure(_ block: () -> Void) -> TimeInterval {
    let startTime = CACurrentMediaTime()
    block()
    return CACurrentMediaTime() - startTime
  }

  /// Measure the execution time of the block.
  ///
  /// Example:
  /// ```swift
  /// // no print
  /// let (result, elapsedTime) = PerformanceMeasurer.measure {
  ///   // some work
  /// }
  /// print("elapsed time: \(elapsedTime)")
  /// ```
  ///
  /// - Parameters:
  ///   - block: The execution block to measure. The block returns a value.
  /// - Returns: The tuple of the value with the elapsed duration.
  @discardableResult
  static func measure<Result>(_ block: () throws -> Result) rethrows -> (Result, TimeInterval) {
    let startTime = CACurrentMediaTime()
    let result = try block()
    let timeElapsed = CACurrentMediaTime() - startTime
    return (result, timeElapsed)
  }

  /// Measure the execution time of the block.
  ///
  /// Example:
  /// ```swift
  /// // no print
  /// let (result, elapsedTime) = try await PerformanceMeasurer.measure {
  ///   try await foo()
  /// }
  /// print("elapsed time: \(elapsedTime)")
  /// ```
  ///
  /// - Parameters:
  ///   - block: The execution block to measure. The block returns a value.
  /// - Returns: The tuple of the value with the elapsed duration.
  @discardableResult
  static func measure<Result>(_ block: () async throws -> Result) async rethrows -> (Result, TimeInterval) {
    let startTime = CACurrentMediaTime()
    let result = try await block()
    let timeElapsed = CACurrentMediaTime() - startTime
    return (result, timeElapsed)
  }
}

// MARK: - Repeat

public extension PerformanceMeasurer {

  /**
    Measure the execution time of the block by repeating the block multiple times and print the elapsed time.

    Example:
    ```swift
    PerformanceMeasurer.measure(tag: "uuid", tagLength: 11, repeatCount: 10000) {
      _ = UUID().uuidString
    }

    PerformanceMeasurer.measure(tag: "mach-string", tagLength: 11, repeatCount: 10000) {
      _ = MachTimeId.idString()
    }

    PerformanceMeasurer.measure(tag: "mach", tagLength: 11, repeatCount: 10000) {
      _ = MachTimeId.id()
    }

    PerformanceMeasurer.measure(tag: "random10", tagLength: 11, repeatCount: 10000) {
      _ = RandomID.new(10)
    }

    [uuid       ] Elapsed time: 0.0054319583578035235
    [mach-string] Elapsed time: 0.0029193332884460688
    [mach       ] Elapsed time: 0.0027786666760221124

    [uuid       ] Elapsed time: 0.00512104167137295
    [mach-string] Elapsed time: 0.0030456666136160493
    [mach       ] Elapsed time: 0.0027735416661016643

    [uuid       ] Elapsed time: 0.005418374959845096
    [mach-string] Elapsed time: 0.0030212916317395866
    [mach       ] Elapsed time: 0.0027525416808202863

    [uuid       ] Elapsed time: 0.005084541626274586
    [mach-string] Elapsed time: 0.0024255000171251595
    [mach       ] Elapsed time: 0.002089166664518416
    [random10   ] Elapsed time: 0.087066333333496
    ```

    - Parameters:
      - tag: The tag for the print log. If not provided, will not print.
      - tagLength: The tag min length. If the tag is shorter than this length, it will be padded with `tagPad`.
      - tagPad: The padding character if the tag is shorter than `tagLength`.
      - useScientificNumber: If should use scientific number.
      - repeatCount: The repeat count to run the block.
      - block: The block to measure.
    - Returns: The total execution time.
   */
  @discardableResult
  static func measure(tag: String? = nil,
                      tagLength: Int? = nil,
                      tagPad: Character? = nil,
                      useScientificNumber: Bool = false,
                      repeatCount: Int,
                      _ block: BlockThrowsVoid) rethrows -> CFTimeInterval
  {
    let startTime = CACurrentMediaTime()

    for _ in 0 ..< repeatCount {
      try block()
    }

    let timeElapsed = CACurrentMediaTime() - startTime

    if var tag = tag {
      if let tagLength {
        tag = tag.padding(toLength: max(tag.count, tagLength), withPad: tagPad.map { String($0) } ?? " ", startingAt: 0)
      }

      if useScientificNumber {
        // swiftlint:disable:next force_unwrapping
        Swift.print("[\(tag)] Elapsed time: \(PerformanceMeasurer.numberFormatter.string(for: timeElapsed)!)")
      } else {
        Swift.print("[\(tag)] Elapsed time: \(timeElapsed)")
      }
    }

    return timeElapsed
  }

  /// Measure the execution time of the block by repeating the block multiple times and print the elapsed time.
  ///
  /// - Parameters:
  ///   - tag: The tag for the print log. If not provided, will not print.
  ///   - tagLength: The tag min length. If the tag is shorter than this length, it will be padded with `tagPad`.
  ///   - tagPad: The padding character if the tag is shorter than `tagLength`.
  ///   - useScientificNumber: If should use scientific number.
  ///   - repeatCount: The repeat count to run the block.
  ///   - block: The block to measure.
  /// - Returns: The total execution time.
  @discardableResult
  static func measure(tag: String? = nil,
                      tagLength: Int? = nil,
                      tagPad: Character? = nil,
                      useScientificNumber: Bool = false,
                      repeatCount: Int,
                      _ block: BlockAsyncThrowsVoid) async rethrows -> CFTimeInterval
  {
    let startTime = CACurrentMediaTime()

    for _ in 0 ..< repeatCount {
      try await block()
    }

    let timeElapsed = CACurrentMediaTime() - startTime

    if var tag = tag {
      if let tagLength {
        tag = tag.padding(toLength: max(tag.count, tagLength), withPad: tagPad.map { String($0) } ?? " ", startingAt: 0)
      }

      if useScientificNumber {
        // swiftlint:disable:next force_unwrapping
        Swift.print("[\(tag)] Elapsed time: \(PerformanceMeasurer.numberFormatter.string(for: timeElapsed)!)")
      } else {
        Swift.print("[\(tag)] Elapsed time: \(timeElapsed)")
      }
    }

    return timeElapsed
  }
}

private extension PerformanceMeasurer {

  private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .scientific
    // formatter.positiveFormat = "0.###E+0"
    formatter.positiveFormat = "0.000E+0" // 1.100e-6 instead of 1.1e-6
    formatter.exponentSymbol = "e"
    return formatter
  }()
}

/**
 Ideas:
 - Can make this into a profile utility, so that it can draw a graph.
 */

// References:
//  - https://kandelvijaya.com/2016/10/25/precisiontiminginios/
