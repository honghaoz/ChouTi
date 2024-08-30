//
//  MachTimeId+Interval.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/22/21.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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
