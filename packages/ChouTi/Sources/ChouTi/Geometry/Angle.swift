//
//  Angle.swift
//  ChouTi
//
//  Created by Honghao Zhang on 12/21/22.
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

/// A geometric angle.
///
/// ```
/// let angle: Angle = 45 // by default, number is used in degrees
/// ```
public struct Angle: Hashable, Equatable, Comparable, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {

  /// Zero degree.
  public static let zero = Angle(degrees: 0)

  /// Make an angle from degrees.
  public static func degrees(_ degrees: Double) -> Angle {
    Angle(degrees: degrees)
  }

  /// Make an angle from degrees.
  public static func degrees(_ degrees: Int) -> Angle {
    Angle(degrees: Double(degrees))
  }

  /// Make an angle from radians.
  public static func radians(_ radians: Double) -> Angle {
    Angle(radians: radians)
  }

  /// Make an angle from radians.
  public static func radians(_ radians: Int) -> Angle {
    Angle(radians: Double(radians))
  }

  /// The angle in degrees.
  public let degrees: Double

  /// The angle in radians.
  public let radians: Double

  /// Initialize with degrees.
  ///
  /// - Parameter degrees: The angle in degrees.
  public init(degrees: Double) {
    self.degrees = degrees
    self.radians = degrees.toRadians
  }

  /// Initialize with radians.
  ///
  /// - Parameter radians: The angle in radians.
  public init(radians: Double) {
    self.degrees = radians.toDegrees
    self.radians = radians
  }

  public static func + (left: Angle, right: Angle) -> Angle {
    Angle(degrees: left.degrees + right.degrees)
  }

  public static func - (left: Angle, right: Angle) -> Angle {
    Angle(degrees: left.degrees - right.degrees)
  }

  public static func += (left: inout Angle, right: Angle) {
    left = Angle(degrees: left.degrees + right.degrees)
  }

  public static func -= (left: inout Angle, right: Angle) {
    left = Angle(degrees: left.degrees - right.degrees)
  }

  public static prefix func - (angle: Angle) -> Angle {
    Angle(degrees: -angle.degrees)
  }

  // MARK: - Comparable

  public static func < (lhs: Angle, rhs: Angle) -> Bool {
    lhs.degrees < rhs.degrees
  }

  // MARK: - ExpressibleByIntegerLiteral

  public typealias IntegerLiteralType = Int

  /// Initialize with an integer literal.
  ///
  /// - Parameter value: The angle in degrees.
  public init(integerLiteral value: Int) {
    self.init(degrees: Double(value))
  }

  // MARK: - ExpressibleByFloatLiteral

  public typealias FloatLiteralType = Double

  /// Initialize with a float literal.
  ///
  /// - Parameter value: The angle in degrees.
  public init(floatLiteral value: Double) {
    self.init(degrees: value)
  }
}
