//
//  Duration.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public enum Duration: Comparable {

  case zero

  /// 1/1000,000,000 of second
  case nanoseconds(Double)

  /// 1/1000,000 of second
  case microseconds(Double)

  /// 1/1000 of second
  case milliseconds(Double)

  case seconds(Double)
  case minutes(Double)
  case hours(Double)
  case days(Double)
  case weeks(Double)
  case months(Double)
  case years(Double)
  case forever

  // MARK: - TimeInterval

  /// Get duration in seconds
  public var seconds: TimeInterval {
    switch self {
    case .zero:
      return 0
    case .nanoseconds(let amount):
      return amount / 1e9
    case .microseconds(let amount):
      return amount / 1e6
    case .milliseconds(let amount):
      return amount / 1e3
    case .seconds(let amount):
      return amount
    case .minutes(let amount):
      return 60 * amount
    case .hours(let amount):
      return 60 * 60 * amount
    case .days(let amount):
      return 60 * 60 * 24 * amount
    case .weeks(let amount):
      return 60 * 60 * 24 * 7 * amount
    case .months(let amount):
      return 60 * 60 * 24 * 30 * amount
    case .years(let amount):
      return 60 * 60 * 24 * 365 * amount
    case .forever:
      return .infinity
    }
  }

  /// Get duration in milliseconds.
  @inlinable
  @inline(__always)
  public var milliseconds: TimeInterval {
    seconds * 1e3
  }

  /// Get duration in microseconds.
  @inlinable
  @inline(__always)
  public var microseconds: TimeInterval {
    seconds * 1e6
  }

  /// Get duration in nanoseconds.
  @inlinable
  @inline(__always)
  public var nanoseconds: TimeInterval {
    seconds * 1e9
  }

  // MARK: - DispatchTimeInterval

  /// Convert `Duration` to `DispatchTimeInterval`.
  ///
  /// - Parameter assertIfNotExact: If should assert the conversion is exact. `DispatchTimeInterval` only supports nanoseconds precision.
  ///   For duration like `.seconds(0.5859688448927677)`, it can't be represented in `DispatchTimeInterval` exactly.
  /// - Returns: A converted `DispatchTimeInterval`.
  public func dispatchTimeInterval(assertIfNotExact: Bool = true) -> DispatchTimeInterval {
    switch self {
    case .zero:
      return .nanoseconds(0)
    case .nanoseconds(let amount):
      guard let integer = Int(exactly: amount) else {
        if !Thread.current.isRunningXCTest, assertIfNotExact {
          ChouTi.assertFailure("inaccurate nanoseconds conversion", metadata: [
            "amount": "\(amount)",
          ])
        }
        return .nanoseconds(Int(amount))
      }
      return .nanoseconds(integer)

    case .microseconds(let amount):
      guard let integer = Int(exactly: amount) else {
        guard let nanosecondsInteger = Int(exactly: amount * 1e3) else {
          if !Thread.current.isRunningXCTest, assertIfNotExact {
            ChouTi.assertFailure("inaccurate microseconds conversion", metadata: [
              "amount": "\(amount)",
            ])
          }
          return .nanoseconds(Int(amount * 1e3))
        }
        return .nanoseconds(nanosecondsInteger)
      }
      return .microseconds(integer)

    case .milliseconds(let amount):
      guard let integer = Int(exactly: amount) else {
        guard let nanosecondsInteger = Int(exactly: amount * 1e6) else {
          if !Thread.current.isRunningXCTest, assertIfNotExact {
            ChouTi.assertFailure("inaccurate milliseconds conversion", metadata: [
              "amount": "\(amount)",
            ])
          }
          return .nanoseconds(Int(amount * 1e6))
        }
        return .nanoseconds(nanosecondsInteger)
      }
      return .milliseconds(integer)

    case .seconds(let amount):
      guard let integer = Int(exactly: amount) else {
        guard let nanosecondsInteger = Int(exactly: amount * 1e9) else {
          if !Thread.current.isRunningXCTest, assertIfNotExact {
            ChouTi.assertFailure("inaccurate seconds conversion", metadata: [
              "amount": "\(amount)",
            ])
          }
          return .nanoseconds(Int(amount * 1e9))
        }
        return .nanoseconds(nanosecondsInteger)
      }
      return .seconds(integer)

    case .minutes,
         .hours,
         .days,
         .weeks,
         .months,
         .years:
      let amount = seconds
      guard let integer = Int(exactly: amount) else {
        guard let nanosecondsInteger = Int(exactly: amount * 1e9) else {
          if !Thread.current.isRunningXCTest, assertIfNotExact {
            ChouTi.assertFailure("inaccurate conversion", metadata: [
              "amount": "\(amount)",
            ])
          }
          return .nanoseconds(Int(amount * 1e9))
        }
        return .nanoseconds(nanosecondsInteger)
      }
      return .seconds(integer)
    case .forever:
      return .never
    }
  }

  // MARK: - Comparable

  public static func < (lhs: Duration, rhs: Duration) -> Bool {
    lhs.seconds < rhs.seconds
  }
}

public extension Date {

  @inlinable
  @inline(__always)
  func adding(_ duration: Duration) -> Date {
    addingTimeInterval(duration.seconds)
  }

  @inlinable
  @inline(__always)
  func adding(_ timeInterval: TimeInterval) -> Date {
    addingTimeInterval(timeInterval)
  }

  @inlinable
  @inline(__always)
  func subtracting(_ duration: Duration) -> Date {
    addingTimeInterval(-duration.seconds)
  }

  @inlinable
  @inline(__always)
  func subtracting(_ timeInterval: TimeInterval) -> Date {
    addingTimeInterval(-timeInterval)
  }

  /// Return true if the time has been for example 60s, inclusive.
  @inlinable
  @inline(__always)
  func hasBeen(_ duration: Duration, since: Date) -> Bool {
    timeIntervalSince(since) >= duration.seconds
  }
}
