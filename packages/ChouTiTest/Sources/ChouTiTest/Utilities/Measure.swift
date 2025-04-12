//
//  Measure.swift
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

import Foundation

/// Measure the execution time of the block with a given repeat count.
///
/// Example:
/// ```swift
/// let elapsedTime = measure(repeat: 1000) {
///   // some work...
/// }
/// print("elapsed time: \(elapsedTime)")
/// ```
///
/// - Parameters:
///   - repeat: The repeat count.
///   - block: The execution block to measure.
/// - Returns: The elapsed time in seconds.
public func measure(repeat: Int = 1, _ block: () -> Void) -> TimeInterval {
  let startTime = mach_absolute_time()
  for _ in 0 ..< `repeat` {
    block()
  }
  return machTimeInterval(from: startTime, to: mach_absolute_time())
}

/// Measure the execution time of the block with a given repeat count.
///
/// Example:
/// ```swift
/// let elapsedTime = try measure(repeat: 1000) {
///   try foo()
/// }
/// print("elapsed time: \(elapsedTime)")
/// ```
///
/// - Parameters:
///   - repeat: The repeat count.
///   - block: The execution block to measure.
/// - Returns: The elapsed time in seconds.
public func measure(repeat: Int = 1, _ block: () throws -> Void) rethrows -> TimeInterval {
  let startTime = mach_absolute_time()
  for _ in 0 ..< `repeat` {
    try block()
  }
  return machTimeInterval(from: startTime, to: mach_absolute_time())
}

/// Measure the execution time of the block with a given repeat count.
///
/// Example:
/// ```swift
/// let elapsedTime = try await measure(repeat: 1000) {
///   try await foo()
/// }
/// print("elapsed time: \(elapsedTime)")
/// ```
///
/// - Parameters:
///   - repeat: The repeat count.
///   - block: The execution block to measure.
/// - Returns: The elapsed time in seconds.
public func measure(repeat: Int = 1, _ block: () async throws -> Void) async rethrows -> TimeInterval {
  let startTime = mach_absolute_time()
  for _ in 0 ..< `repeat` {
    try await block()
  }
  return machTimeInterval(from: startTime, to: mach_absolute_time())
}

/// Get the time interval between two `mach_absolute_time()` calls.
/// - Parameters:
///   - start: The start value returned from `mach_absolute_time()`.
///   - end: The end value returned from `mach_absolute_time()`.
/// - Returns: The time interval between `start` to `end`.
private func machTimeInterval(from start: UInt64, to end: UInt64) -> TimeInterval {
  var info = mach_timebase_info()
  guard mach_timebase_info(&info) == KERN_SUCCESS else {
    return -1
  }
  let elapsed = end - start
  let nanos = elapsed * UInt64(info.numer) / UInt64(info.denom)
  return TimeInterval(nanos) / TimeInterval(NSEC_PER_SEC)
}
