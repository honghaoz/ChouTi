//
//  PerformanceMeasurer.swift
//
//  Created by Honghao Zhang on 12/12/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import QuartzCore

public final class PerformanceMeasurer {

  private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .scientific
    // formatter.positiveFormat = "0.###E+0"
    formatter.positiveFormat = "0.000E+0" // 1.100e-6 instead of 1.1e-6
    formatter.exponentSymbol = "e"
    return formatter
  }()

  // MARK: - Two calls

  public static var startTime: CFTimeInterval?
  public static func start(tag: String = "Unspecified") {
    startTime = CACurrentMediaTime()
  }

  public static func end(tag: String = "Unspecified") {
    guard let startTime else {
      logger.warning("Unbalanced end() call.")
      return
    }
    let timeElapsed = CACurrentMediaTime() - startTime
    print("[\(tag)] elapsed time: \(timeElapsed)")
    self.startTime = nil
  }

  // MARK: - With block

  // From: https://www.objc.io/blog/2018/06/14/quick-performance-timing/

  /**
   Run and measure.

   Example:
   ```
   let (_, timeElapsed) = PerformanceMeasurer.measure {
     // some work
   }
   print("Elapsed Time: \(timeElapsed)")
   ```

   - Parameter block: The execution block, which returns a value.
   - Returns: The tuple of the value with the elapsed duration.
   */
  @discardableResult
  public static func measure<A>(_ block: () throws -> A) throws -> (A, TimeInterval) {
    let startTime = CACurrentMediaTime()
    let result = try block()
    let timeElapsed = CACurrentMediaTime() - startTime
    return (result, timeElapsed)
  }

  /// Run and measure.
  ///
  /// - Parameter block: The execution block, which returns a value.
  /// - Returns: The tuple of the value with the elapsed duration.
  @discardableResult
  public static func measure<A>(_ block: () -> A) -> (A, TimeInterval) {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    return (result, timeElapsed)
  }

  /// Run and measure.
  ///
  /// Example:
  /// ```
  /// let numbers = Array(1...10_000)
  /// let elapsedTime = PerformanceMeasurer.measure {
  ///   _ = numbers.concurrentMap { $0 * $0 }
  /// }
  /// ```
  /// - Parameter block: The execution code.
  /// - Returns: The elapsed duration.
  @discardableResult
  public static func measure(_ block: () -> Void) -> TimeInterval {
    let startTime = CACurrentMediaTime()
    block()
    let timeElapsed = CACurrentMediaTime() - startTime
    return timeElapsed
  }

  /// Measure and print result
  ///
  /// Example:
  /// ```
  /// let value = PerformanceMeasurer.measure(tag: "hash") {
  ///   AnyHashable(wrappedNode.hashValue)
  /// }
  /// ```
  public static func measure<T>(tag: String = "unspecified", _ block: () throws -> T) rethrows -> T {
    let startTime = CACurrentMediaTime()
    let result = try block()
    let timeElapsed = CACurrentMediaTime() - startTime
    print("[\(tag)] elapsed time: \(timeElapsed)")
    return result
  }

  /**
   Measure by running the block X times and print the elapsed time.

   Example:
   ```
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

   [uuid       ] elapsed time: 0.0054319583578035235
   [mach-string] elapsed time: 0.0029193332884460688
   [mach       ] elapsed time: 0.0027786666760221124

   [uuid       ] elapsed time: 0.00512104167137295
   [mach-string] elapsed time: 0.0030456666136160493
   [mach       ] elapsed time: 0.0027735416661016643

   [uuid       ] elapsed time: 0.005418374959845096
   [mach-string] elapsed time: 0.0030212916317395866
   [mach       ] elapsed time: 0.0027525416808202863

   [uuid       ] elapsed time: 0.005084541626274586
   [mach-string] elapsed time: 0.0024255000171251595
   [mach       ] elapsed time: 0.002089166664518416
   [random10   ] elapsed time: 0.087066333333496
   ```

   - Parameters:
     - tag: The tag for the print log.
     - tagLength: The tag min length, if tag string is short, will use `tagPad` character to fill.
     - tagPad: The padding character.
     - repeatCount: The repeating count for running the block.
     - block: The block to measure.
   */
  public static func measure(tag: String = "unspecified", tagLength: Int? = nil, tagPad: Character? = nil, repeatCount: Int, _ block: BlockVoid) {
    let startTime = CACurrentMediaTime()
    for _ in 0 ..< repeatCount {
      block()
    }
    let timeElapsed = CACurrentMediaTime() - startTime
    var tag = tag
    if let tagLength {
      tag = tag.padding(toLength: max(tag.count, tagLength), withPad: tagPad.map { String($0) } ?? " ", startingAt: 0)
    }
    print("[\(tag)] elapsed time: \(timeElapsed)")
  }

  // MARK: - Instance

  private let tag: String?
  private let tagLength: Int?
  private let tagPad: Character?

  private let useScientificNumber: Bool
  private var startTime: CFTimeInterval?

  public init(tag: String? = nil, tagLength: Int? = nil, tagPad: Character? = nil, useScientificNumber: Bool = false) {
    self.tag = tag
    self.tagLength = tagLength
    self.tagPad = tagPad
    self.useScientificNumber = useScientificNumber
  }

  public func start() {
    startTime = CACurrentMediaTime()
  }

  public func end() {
    guard let startTime else {
      logger.warning("Unbalanced end() call.")
      return
    }
    let timeElapsed = CACurrentMediaTime() - startTime

    var tag = tag ?? "unspecified"
    if let tagLength {
      tag = tag.padding(toLength: max(tag.count, tagLength), withPad: tagPad.map { String($0) } ?? " ", startingAt: 0)
    }
    if useScientificNumber {
      // swiftlint:disable:next force_unwrapping
      print("[\(tag)] elapsed time: \(PerformanceMeasurer.numberFormatter.string(for: timeElapsed)!)")
    } else {
      print("[\(tag)] elapsed time: \(timeElapsed)")
    }
    self.startTime = nil
  }
}

/**
 Ideas:
 - Can make this into a profile utility, so that it can draw a graph.
 */

// References:
//  - https://kandelvijaya.com/2016/10/25/precisiontiminginios/
