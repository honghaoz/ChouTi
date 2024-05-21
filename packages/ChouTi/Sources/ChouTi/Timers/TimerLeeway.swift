//
//  TimerLeeway.swift
//
//  Created by Honghao Zhang on 11/13/22.
//  Copyright © 2024 ChouTi. All rights reserved.
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
