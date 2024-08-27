//
//  Clamp.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

// MARK: - Comparable + Clamp

public extension Comparable {

  // MARK: - ClosedRange

  /// Return a clamped `value` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// 150.clamped(to: 0...100) -> 100
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  /// - Returns: The clamped value.
  func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(limits.lowerBound, self), limits.upperBound)
  }

  /// Clamping `self` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// var num = 150
  /// num.clamping(to: 0...100)
  /// print(num) // 100
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  mutating func clamping(to limits: ClosedRange<Self>) {
    self = clamped(to: limits)
  }

  // MARK: - PartialRangeFrom

  /// Return a clamped `value` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// 10.clamped(to: 100...) -> 100
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  /// - Returns: The clamped value.
  func clamped(to limits: PartialRangeFrom<Self>) -> Self {
    max(limits.lowerBound, self)
  }

  /// Return a clamped `value` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// 150.clamped(to: ...100) -> 100
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  /// - Returns: The clamped value.
  func clamped(to limits: PartialRangeThrough<Self>) -> Self {
    min(self, limits.upperBound)
  }

  /// Clamping `self` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// var num = 10
  /// num.clamping(to: 100...)
  /// print(num) // 100
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  mutating func clamping(to limits: PartialRangeFrom<Self>) {
    self = clamped(to: limits)
  }

  /// Clamping `self` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// var num = 150
  /// num.clamping(to: ...100)
  /// print(num) // 10
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  mutating func clamping(to limits: PartialRangeThrough<Self>) {
    self = clamped(to: limits)
  }
}

// MARK: - Int + Clamp

public extension Int {

  /// Return a clamped `value` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// 10.clamped(to: 0 ..< 10) -> 9
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  /// - Returns: The clamped value.
  func clamped(to limits: Range<Int>) -> Int {
    Swift.min(Swift.max(limits.lowerBound, self), limits.upperBound - 1)
  }

  /// Clamping `self` to the given limiting range.
  ///
  /// Example:
  /// ```
  /// var num = 10
  /// num.clamping(to: 0 ..< 10)
  /// print(num) // 9
  /// ```
  ///
  /// - Parameter limits: Range to clamp.
  mutating func clamping(to limits: Range<Int>) {
    self = clamped(to: limits)
  }
}
