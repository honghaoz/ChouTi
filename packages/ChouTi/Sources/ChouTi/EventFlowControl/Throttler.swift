//
//  Throttler.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/8/20.
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

/**
 A throttler that limits the frequency of function calls over time.

 Throttling ensures that a function is called at most once within a specified time interval,
 regardless of how many times the function is invoked.

 There are two modes of operation:
 1. Latest: Executes the most recent function call at the end of each interval.
 2. First: Executes the first function call received in each interval.

 Visualization:
 ```
 [latest]
 original events:  1 2 3 4 5 6 7
 time interval:    |    |     |
 throttled events:      3     6

 [first]
 original events:  1 2 3 4 5 6 7
 time interval:    |    |     |
 throttled events:      1     4
 ```

 Usage example:
 ```swift
 let throttler = Throttler(interval: 0.01, latest: true)

 throttler.throttle {
   // do you work
 }
 ```

 - Note: This throttler is not thread-safe. You should make sure `throttle(block:)` calls are made from the same thread.
 */
public final class Throttler {

  private let interval: TimeInterval
  private let latest: Bool
  private let queue: DispatchQueue

  private let invokeImmediately: Bool
  private var lastFireTime: TimeInterval = Date.distantPast.timeIntervalSince1970

  private var delayTask: CancellableToken?
  private var blockToCall: BlockVoid?

  private var clock: Clock = SystemClock()

  /// Initialize a new throttler.
  ///
  /// - Parameters:
  ///   - interval: The throttling interval. The interval should be greater than 0.
  ///   - latest: If should invoke the latest block received during the delay.
  ///   - invokeImmediately: If should invoke the block immediately if the time interval is already passed since the last fire time. Default value is `false`.
  ///   - queue: The queue used to invoke the throttled block.
  public init(interval: TimeInterval, latest: Bool, invokeImmediately: Bool = false, queue: DispatchQueue = .main) {
    ChouTi.assert(interval > 0, "The interval should be greater than 0.")
    self.interval = max(interval, 0)
    self.latest = latest
    self.queue = queue
    self.invokeImmediately = invokeImmediately
  }

  /// Throttle a block.
  ///
  /// - Parameter block: The block to be throttled.
  public func throttle(block: @escaping BlockVoid) {
    if latest {
      // always update to latest block
      blockToCall = block
    } else {
      // if already set, don't update the block
      if blockToCall == nil {
        blockToCall = block
      }
    }

    // if there's a delay task, throttler is running, no action needed.
    guard delayTask == nil else {
      return
    }

    let scheduleDelayTask: (TimeInterval) -> Void = { delay in
      if delay <= 0 {
        self.blockToCall?()
        self.blockToCall = nil
        self.lastFireTime = self.clock.now()
        return
      } else {
        self.delayTask = self.clock.delay(delay, queue: self.queue) { [weak self] in
          guard let self = self else {
            return
          }
          self.blockToCall?()
          self.blockToCall = nil
          self.lastFireTime = clock.now()
          self.delayTask = nil
        }
      }
    }

    if invokeImmediately {
      let delayTime = interval - (clock.now() - lastFireTime)
      if delayTime <= 0 {
        // if the time interval is already passed since the last fire time, invoke the block immediately.
        blockToCall?()
        blockToCall = nil
        lastFireTime = clock.now()
        return
      } else {
        scheduleDelayTask(delayTime)
      }
    } else {
      scheduleDelayTask(interval)
    }
  }

  // MARK: - Testing

  #if DEBUG

  var test: Test { Test(host: self) }

  class Test {

    private let host: Throttler

    fileprivate init(host: Throttler) {
      ChouTi.assert(Thread.isRunningXCTest, "test namespace should only be used in test target.")
      self.host = host
    }

    var clock: Clock {
      get { host.clock }
      set { host.clock = newValue }
    }
  }

  #endif
}

// - See also:
//   - https://css-tricks.com/debouncing-throttling-explained-examples/
//   - https://medium.com/@ellenaua/throttle-debounce-behavior-lodash-6bcae1494e03
