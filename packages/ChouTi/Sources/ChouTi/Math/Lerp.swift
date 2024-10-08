//
//  Lerp.swift
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
public func lerp<T: BinaryFloatingPoint>(start: T, end: T, t: T) -> T {
  // https://en.wikipedia.org/wiki/Linear_interpolation
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
