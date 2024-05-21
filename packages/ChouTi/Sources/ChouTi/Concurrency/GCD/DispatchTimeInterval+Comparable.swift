//
//  DispatchTimeInterval+Comparable.swift
//
//  Created by Honghao Zhang on 3/28/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

extension DispatchTimeInterval: Comparable {

  public static func < (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
    lhs.nonOptionalTimeInterval < rhs.nonOptionalTimeInterval
  }

  public static func > (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
    lhs.nonOptionalTimeInterval > rhs.nonOptionalTimeInterval
  }

  private var nonOptionalTimeInterval: TimeInterval {
    switch self {
    case .seconds(let value):
      return TimeInterval(value)
    case .milliseconds(let value):
      return TimeInterval(value) * 0.001
    case .microseconds(let value):
      return TimeInterval(value) * 0.000001
    case .nanoseconds(let value):
      return TimeInterval(value) * 0.000000001
    case .never:
      return TimeInterval.greatestFiniteMagnitude
    @unknown default:
      return TimeInterval.greatestFiniteMagnitude
    }
  }
}
