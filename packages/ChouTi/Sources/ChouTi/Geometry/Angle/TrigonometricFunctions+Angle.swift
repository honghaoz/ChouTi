//
//  TrigonometricFunctions+Angle.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/2/24.
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

/// Returns the sine of the angle.
///
/// - Parameter angle: The angle.
/// - Returns: The sine of the angle.
@inlinable
@inline(__always)
public func sin(_ angle: Angle) -> Double {
  sin(angle.radians)
}

/// Returns the cosine of the angle.
///
/// - Parameter angle: The angle.
/// - Returns: The cosine of the angle.
@inlinable
@inline(__always)
public func cos(_ angle: Angle) -> Double {
  cos(angle.radians)
}

/// Returns the tangent of the angle.
///
/// - Parameter angle: The angle.
/// - Returns: The tangent of the angle.
@inlinable
@inline(__always)
public func tan(_ angle: Angle) -> Double {
  tan(angle.radians)
}

/// Returns the angle whose sine is the specified value.
///
/// - Parameter value: The value.
/// - Returns: The angle.
@inlinable
@inline(__always)
public func asin(_ value: Double) -> Angle {
  Angle(radians: asin(value))
}

/// Returns the angle whose cosine is the specified value.
///
/// - Parameter value: The value.
/// - Returns: The angle.
@inlinable
@inline(__always)
public func acos(_ value: Double) -> Angle {
  Angle(radians: acos(value))
}

/// Returns the angle whose tangent is the specified value.
///
/// - Parameter value: The value.
/// - Returns: The angle.
@inlinable
@inline(__always)
public func atan(_ value: Double) -> Angle {
  Angle(radians: atan(value))
}

// https://www.swift.org/blog/numerics/
// https://en.wikipedia.org/wiki/Sine_and_cosine
// https://en.wikipedia.org/wiki/Hyperbolic_function
