//
//  Debouncer.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/25/20.
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

// MARK: - LeadingDebouncer

/**
 A leading (or immediate) debouncer that limits the frequency of events (e.g. button taps).

 The debouncer triggers the call immediately and ignores subsequent calls within the specified interval.

 Visualization:
 ```
 Time:             0----1----2----3----4----5----6----7----8----
 Original events:  *--**----*---*----**---*-----*--*------*-----
 Interval:         ---
 Debounced events: *--------*---*----*----*-----*---------*-----
 ```

 Usage examples:
 1. Using `debounce()`:
 ```swift
 let debouncer = LeadingDebouncer(interval: 1)
 guard debouncer.debounce() else {
   // skipped
 }
 // good to execute
 ```

 2. Using the closure-based method `debounce(block:)`:
 ```swift
 let debouncer = LeadingDebouncer(interval: 1)
 debouncer.debounce {
   // this will be executed if the elapsed time is greater than 1s.
 }
 ```

 - Note: This debouncer is not thread-safe. You should make sure `debounce()` and `debounce(block:)` calls are made from the same thread.
 */
public final class LeadingDebouncer {

  private let interval: TimeInterval
  private var lastRunTime: TimeInterval = Date.distantPast.timeIntervalSince1970

  private var clock: Clock = ClockProvider.current

  /// Initialize a LeadingDebouncer.
  ///
  /// - Parameter interval: The debounce interval. The interval should be greater than 0.
  public init(interval: TimeInterval) {
    ChouTi.assert(interval > 0, "The interval should be greater than 0.")
    if interval <= 0 {
      self.interval = -.leastNonzeroMagnitude // meaning always trigger
    } else {
      self.interval = interval
    }
  }

  /// Check if it's good to pass the debounce.
  ///
  /// - Returns: `true` if it's good to pass the debounce.
  public func debounce() -> Bool {
    let now = clock.now()
    defer {
      lastRunTime = now
    }
    if now - lastRunTime > interval {
      return true // only trigger event if the gap is greater than the interval
    } else {
      return false
    }
  }

  /// Debounce with a callback block.
  ///
  /// - Parameter block: The block to debounce, it will be called synchronously if the debounce is good to pass.
  public func debounce(block: () -> Void) {
    let now = clock.now()
    defer {
      lastRunTime = now
    }
    if now - lastRunTime > interval {
      block()
    }
  }
}

// MARK: - TrailingDebouncer

/**
 A trailing debouncer that limits the frequency of events (e.g. button taps).

 This debouncer delays the execution of a block until a specified time interval has passed since the last invocation.
 If the block is called multiple times within the interval, only the last call will be executed after the interval elapses.

 Visualization:
 ```
 Time:             0----1----2----3----4----5----6----7----8----
 Original events:  *--◯●----□----*----◯●--□-----*--◯----●-□-----
 Interval:         ---
 Debounced events: --------●----□----*--------□--------◯------□-
 ```

 Usage examples:
 ```swift
 let debouncer = TrailingDebouncer(interval: 1, queue: privateQueue)
 debouncer.debounce {
   // this will be executed if the elapsed time is greater than 1s.
 }
 ```

 - Note: This debouncer is not thread-safe. You should make sure `debounce(block:)` calls are made from the same thread.
 */
public final class TrailingDebouncer {

  private let interval: TimeInterval
  private let queue: DispatchQueue

  private var delayedTask: CancellableToken?

  private var clock: Clock = ClockProvider.current

  /// Initialize a TrailingDebouncer.
  ///
  /// - Parameters:
  ///   - interval: The debounce interval. The interval should be greater than 0.
  ///   - queue: The queue used to invoke the debounced block.
  public init(interval: TimeInterval, queue: DispatchQueue = .main) {
    ChouTi.assert(interval > 0, "The interval should be greater than 0.")
    self.interval = max(interval, 0)
    self.queue = queue
  }

  /// Invoke a block in a trailing debounced manner.
  ///
  /// - Parameter block: The block to be invoked after the debounce interval.
  /// - Returns: Returns `true` if a previous block was debounced.
  @discardableResult
  public func debounce(block: @escaping () -> Void) -> Bool {
    if interval <= 0 {
      block()
      return true
    }

    var lastTaskWasCancelled = false

    if delayedTask != nil {
      delayedTask?.cancel()
      delayedTask = nil
      lastTaskWasCancelled = true
    }

    delayedTask = clock.delay(interval, queue: queue) { [weak self] in
      block()
      self?.delayedTask = nil
    }

    return lastTaskWasCancelled
  }
}

/// - See also:
///   - https://stackoverflow.com/a/34552145/3164091
///   - https://css-tricks.com/debouncing-throttling-explained-examples/
