//
//  DispatchTimeInterval+Extensions.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

// MARK: - TimeInterval to DispatchTimeInterval

public extension TimeInterval {

  /// Convert `TimeInterval` to `DispatchTimeInterval`.
  ///
  /// - Parameter assertIfNotExact: If should assert the conversion is exact. `DispatchTimeInterval` only supports nanoseconds precision.
  ///   For interval like `0.5859688448927677`, it can't be represented in `DispatchTimeInterval` exactly.
  /// - Returns: A converted `DispatchTimeInterval`.
  func dispatchTimeInterval(assertIfNotExact: Bool = true) -> DispatchTimeInterval {
    ChouTi.Duration.seconds(self).dispatchTimeInterval(assertIfNotExact: assertIfNotExact)
  }
}

// MARK: - DispatchTimeInterval to TimeInterval

public extension TimeInterval {

  init(dispatchTimeInterval: DispatchTimeInterval) {
    switch dispatchTimeInterval {
    case .nanoseconds(let value):
      self = TimeInterval(value) / 1e9
    case .microseconds(let value):
      self = TimeInterval(value) / 1e6
    case .milliseconds(let value):
      self = TimeInterval(value) / 1e3
    case .seconds(let value):
      self = TimeInterval(value)
    case .never:
      self = .greatestFiniteMagnitude
    @unknown default:
      ChouTi.assertFailure("unknown DispatchTimeInterval: \(dispatchTimeInterval)")
      self = .greatestFiniteMagnitude
    }
  }
}

public extension DispatchTimeInterval {

  /// `DispatchTimeInterval` -> `TimeInterval`.
  var timeInterval: TimeInterval {
    TimeInterval(dispatchTimeInterval: self)
  }
}
