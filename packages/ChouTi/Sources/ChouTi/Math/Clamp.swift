//
//  Clamp.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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
