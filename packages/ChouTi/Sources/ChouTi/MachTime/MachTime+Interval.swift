//
//  MachTime+Interval.swift
//
//  Created by Honghao Zhang on 5/22/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension MachTimeId {

  /// Get the time interval between two `mach_absolute_time()` calls.
  func interval(since time: MachTimeId) -> TimeInterval {
    machTimeInterval(from: time, to: self)
  }
}

/// Get the time interval between two `mach_absolute_time()` calls.
/// - Parameters:
///   - start: The start value returned from `mach_absolute_time()`.
///   - end: The end value returned from `mach_absolute_time()`.
/// - Returns: The time interval between `start` to `end`.
public func machTimeInterval(from start: UInt64, to end: UInt64) -> TimeInterval {
  var info = mach_timebase_info()
  guard mach_timebase_info(&info) == KERN_SUCCESS else {
    return -1
  }
  let elapsed = end - start
  let nanos = elapsed * UInt64(info.numer) / UInt64(info.denom)
  return TimeInterval(nanos) / TimeInterval(NSEC_PER_SEC)
}
