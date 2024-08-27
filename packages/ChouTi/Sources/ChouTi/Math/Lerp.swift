//
//  Lerp.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// Linear interpolation between two values.
///
/// Example:
/// ```
/// lerp(start: 0, end: 10, t: 0.5) -> 5
/// ```
///
/// - Parameters:
///   - start: The start value.
///   - end: The end value.
///   - t: The interpolation value between the two floats. The value is clamped to the range [0, 1].
/// - Returns: The interpolated value between the two values.
///
/// - Note: https://en.wikipedia.org/wiki/Linear_interpolation
public func lerp<T: BinaryFloatingPoint>(start: T, end: T, t: T) -> T {
  start + (end - start) * t.clamped(to: 0.0 ... 1.0)
}

public extension BinaryFloatingPoint {

  /// Linear interpolation between `self` and an end value.
  ///
  /// - Parameters:
  ///   - end: The end value.
  ///   - t: The interpolation value between the two floats. The value is clamped to the range [0, 1].
  /// - Returns: The interpolated value between the two values.
  func lerp(end: Self, t: Self) -> Self {
    self + (end - self) * t.clamped(to: 0.0 ... 1.0)
  }
}
