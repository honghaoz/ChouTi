//
//  TimerLeeway.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/22.
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

/// The leeway for a timer.
public enum TimerLeeway: Sendable {

  /// Zero leeway.
  /// This will make the timer be strict, which means the system makes its best effort to fire at the correct time.
  case zero

  /// Fixed leeway interval in seconds.
  case seconds(TimeInterval)

  /// Fractional based on firing interval.
  case fractional(Double)

  /// If the leeway is strict.
  public var isStrict: Bool {
    switch self {
    case .zero:
      return true
    case .seconds(let value):
      return value == 0
    case .fractional(let percentage):
      return percentage == 0
    }
  }

  /// Get leeway seconds based on the timer firing interval.
  ///
  /// - Parameter firingInterval: The firing interval of the timer.
  /// - Returns: The leeway interval in seconds.
  public func leewayInterval(from firingInterval: TimeInterval) -> TimeInterval {
    switch self {
    case .zero:
      return 0
    case .seconds(let value):
      ChouTi.assert(value <= firingInterval, "leeway should be less than or equal to the firing interval.")
      return value
    case .fractional(let percentage):
      ChouTi.assert(percentage <= 1, "leeway percentage should be less than or equal to 1.")
      return firingInterval * percentage
    }
  }

  /// Get leeway dispatch time interval based on the timer firing interval.
  /// - Parameter firingInterval: The firing interval of the timer.
  /// - Returns: The leeway dispatch time interval.
  public func dispatchTimeInterval(from firingInterval: TimeInterval) -> DispatchTimeInterval {
    switch self {
    case .zero:
      return .nanoseconds(0)
    case .seconds(let value):
      ChouTi.assert(value <= firingInterval, "leeway should be less than or equal to the firing interval.")
      return value.dispatchTimeInterval(assertIfNotExact: false)
    case .fractional(let percentage):
      ChouTi.assert(percentage <= 1, "leeway percentage should be less than or equal to 1.")
      return (firingInterval * percentage).rounded().dispatchTimeInterval(assertIfNotExact: false)
    }
  }
}
