//
//  BinaryFloatingPoint+Round.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/6/21.
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

public extension BinaryFloatingPoint {

  /// Rounds the number to the nearest multiple of a specified step value.
  ///
  /// This method rounds the number to the nearest multiple of the `step` parameter.
  /// It's useful for rounding to specific increments, such as 0.5, 0.25, or any other value.
  ///
  /// Example:
  /// ```
  /// (2.0).round(nearest: 0.5) => 3
  /// (3.0).round(nearest: 0.5) => 3
  /// (3.1).round(nearest: 0.5) => 3
  /// (3.3).round(nearest: 0.5) => 3.5
  /// ```
  ///
  /// - Parameter nearest: The increment to round to. This value determines the "step size" between rounded values.
  /// - Returns: The input value rounded to the nearest multiple of `nearest`.
  func round(nearest: Self) -> Self {
    let n = 1 / nearest
    let numberToRound = self * n
    return numberToRound.rounded() / n
  }

  /// Rounds the number up to the nearest multiple of a specified step value.
  ///
  /// This method rounds the number up to the nearest multiple of the `step` parameter.
  /// It's useful for rounding up to specific increments, such as 0.5, 0.25, or any other value.
  ///
  /// Example:
  /// ```
  /// (3.9).ceil(nearest: 0.5) -> 4.0
  /// (4.0).ceil(nearest: 0.5) -> 4.0
  /// (4.1).ceil(nearest: 0.5) -> 4.5
  /// ```
  ///
  /// - Parameter nearest: The increment to round up to. This value determines the "step size" between rounded values.
  /// - Returns: The input value rounded up to the nearest multiple of `nearest`.
  func ceil(nearest: Self) -> Self {
    let remainder = truncatingRemainder(dividingBy: nearest)
    if remainder.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-12) {
      return self
    } else {
      return self + (nearest - remainder)
    }
  }

  /// Rounds the number down to the nearest multiple of a specified step value.
  ///
  /// Example:
  /// ```
  /// (3.9).floor(nearest: 0.5) -> 3.5
  /// (4.0).floor(nearest: 0.5) -> 4.0
  /// (4.1).floor(nearest: 0.5) -> 4.0
  /// ```
  ///
  /// - Parameter nearest: The increment to round down to. This value determines the "step size" between rounded values.
  /// - Returns: The input value rounded down to the nearest multiple of `nearest`.
  func floor(nearest: Self) -> Self {
    let intDiv = Self(Int(self / nearest))
    return intDiv * nearest
  }
}

// References:
// https://stackoverflow.com/a/38483058/3164091
