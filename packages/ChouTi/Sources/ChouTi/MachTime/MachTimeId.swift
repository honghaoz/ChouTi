//
//  MachTimeId.swift
//
//  Created by Honghao Zhang on 5/22/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An identifier based on mach absolute time.
///
/// ⚠️ Don't use `MachTimeId()`, use `MachTimeId.id()` or `MachTimeId.idString()`.
public typealias MachTimeId = UInt64

public extension MachTimeId {

  /// Make a new id based on mach absolute time.
  ///
  /// This is generally the fastest way to get a unique id within the same app run.
  ///
  /// - Warning: For consecutive calls, the returned ids maybe the same. For this case, you may need to use a variable to store the last id to guarantee the uniqueness. For example:
  /// ```swift
  /// var lastId: MachTimeId = 0
  ///
  /// for _ in 1...100 {
  ///   var newId = MachTimeId.id()
  ///   if newId <= lastId {
  ///     newId = lastId + 1
  ///   }
  ///   lastId = newId
  ///   print(newId)
  /// }
  /// ```
  @inlinable
  @inline(__always)
  static func id() -> MachTimeId {
    mach_absolute_time()
  }

  /// Make a new id string based on mach absolute time.
  ///
  /// This is generally the fastest way to get a unique id within the same app run.
  ///
  /// - Warning: For consecutive calls, the returned ids maybe the same. For this case, you may need to use a variable to store the last id to guarantee the uniqueness. For example:
  /// ```swift
  /// var lastId: String = ""
  ///
  /// for _ in 1...100 {
  ///   var newId = MachTimeId.idString()
  ///   if newId <= lastId {
  ///     newId = lastId + "1"
  ///   }
  ///   lastId = newId
  ///   print(newId)
  /// }
  /// ```
  @inlinable
  @inline(__always)
  static func idString() -> String {
    String(mach_absolute_time())
  }
}

public extension String {

  /// Make a new id string based on mach absolute time.
  @inlinable
  @inline(__always)
  static func machTimeId() -> String {
    MachTimeId.idString()
  }
}

// Reference: https://kandelvijaya.com/2016/10/25/precisiontiminginios/

// -------------------------

/// Get a monotonically increasing number (CPU ticks)
/// https://stackoverflow.com/questions/45551087/when-does-cacurrentmediatime-mach-system-time-wrap-around-on-ios

// https://developer.apple.com/documentation/kernel/1462446-mach_absolute_time
// mach_absolute_time()
// clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

// https://developer.apple.com/documentation/kernel/1646199-mach_continuous_time
// mach_continuous_time()
// clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)

// https://developer.apple.com/documentation/kernel/1462443-mach_approximate_time
// mach_approximate_time()

// https://developer.apple.com/documentation/kernel/1646198-mach_continuous_approximate_time
// mach_continuous_approximate_time()

// https://forums.swift.org/t/recommended-way-to-measure-time-in-swift/33326/17
// DispatchTime.now().uptimeNanoseconds

// for i in 1...10000 {
//   _ = mach_absolute_time()
// }
//
// mach_absolute_time
// 0.0020070416503585875
// 0.0020677499705925584
// 0.001959791698027402
// 0.002017666702158749

// clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
// 0.002042958338279277
// 0.001984375005122274
// 0.002000749984290451
// 0.0020982916466891766

// DispatchTime.now().uptimeNanoseconds
// 0.0022605416597798467
// 0.002244041650556028
// 0.002239791676402092
// 0.0021742083481512964
