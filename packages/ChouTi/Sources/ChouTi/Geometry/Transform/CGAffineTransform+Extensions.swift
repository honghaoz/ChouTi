//
//  CGAffineTransform+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/22/21.
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

import CoreGraphics
import Foundation

public extension CGAffineTransform {

  // MARK: - Conversion

  #if os(macOS)
  /// Converts the Core Graphics affine transform to an affine transform.
  @inlinable
  @inline(__always)
  var affineTransform: AffineTransform {
    AffineTransform(m11: a, m12: b, m21: c, m22: d, tX: tx, tY: ty)
  }
  #endif

  // MARK: - Static

  /// The zero transform.
  static let zero = CGAffineTransform(a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0)

  /// The horizontal flip transform.
  static let horizontalFlip = CGAffineTransform(scaleX: -1, y: 1)

  /// The vertical flip transform.
  static let verticalFlip = CGAffineTransform(scaleX: 1, y: -1)

  /// The diagonal flip transform.
  static let diagonalFlip = CGAffineTransform(scaleX: -1, y: -1)

  // MARK: - Factory

  // MARK: - Translation

  /// Creates a translation transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.translation(x: 10, y: 20)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the translation.
  ///   - y: The y-coordinate of the translation.
  /// - Returns: The translation transform.
  @inlinable
  @inline(__always)
  static func translation(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
    CGAffineTransform(translationX: tx, y: ty)
  }

  /// Creates a translation transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.translation(10, 20)
  /// ```
  ///
  /// - Parameters:
  ///   - tx: The x-coordinate of the translation.
  ///   - ty: The y-coordinate of the translation.
  /// - Returns: The translation transform.
  @inlinable
  @inline(__always)
  static func translation(_ tx: CGFloat, _ ty: CGFloat) -> CGAffineTransform {
    CGAffineTransform(translationX: tx, y: ty)
  }

  // MARK: - Scale

  /// Creates a scale transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.scale(x: 10, y: 10)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the scale.
  ///   - y: The y-coordinate of the scale.
  /// - Returns: The scale transform.
  @inlinable
  @inline(__always)
  static func scale(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
    CGAffineTransform(scaleX: sx, y: sy)
  }

  /// Creates a scale transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.scale(10, 10)
  /// ```
  ///
  /// - Parameters:
  ///   - sx: The x-coordinate of the scale.
  ///   - sy: The y-coordinate of the scale.
  /// - Returns: The scale transform.
  @inlinable
  @inline(__always)
  static func scale(_ sx: CGFloat, _ sy: CGFloat) -> CGAffineTransform {
    CGAffineTransform(scaleX: sx, y: sy)
  }

  /// The scale of the transform.
  ///
  /// Example:
  /// ```swift
  /// let scale = transform.scale
  /// ```
  ///
  /// - Returns: The scale of the transform.
  var scale: Double {
    /// https://www.hackingwithswift.com/example-code/core-graphics/how-to-find-the-scale-from-a-cgaffinetransform
    /// https://stackoverflow.com/questions/12040044/how-to-know-the-current-scale-of-a-uiview/12040266#12040266
    sqrt(Double(a * a + c * c))
  }

  // MARK: - Rotation

  /// Creates a rotation transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.rotation(angle: .degrees(45))
  /// ```
  ///
  /// - Parameter angle: The rotation angle.
  /// - Returns: The rotation transform.
  @inlinable
  @inline(__always)
  static func rotation(angle: Angle) -> CGAffineTransform {
    CGAffineTransform(rotationAngle: angle)
  }

  // MARK: - Shear

  /// Creates a shear/skew transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.shear(x: 0.5, y: 0.5)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The horizontal shear factor. Positive values shear to the right, negative to the left.
  ///        A value of 1 means 45 degrees of shear.
  ///   - y: The vertical shear factor. Positive values shear downwards, negative upwards.
  ///        A value of 1 means 45 degrees of shear.
  /// - Returns: The shear transform.
  @inlinable
  @inline(__always)
  static func shear(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
    /// https://stackoverflow.com/a/35759347/3164091
    /// https://forum.patagames.com/posts/t501-What-Is-Transformation-Matrix-and-How-to-Use-It
    CGAffineTransform(a: 1, b: sy, c: sx, d: 1, tx: 0, ty: 0)
  }

  /// Creates a shear/skew transform.
  ///
  /// Example:
  /// ```swift
  /// CGAffineTransform.shear(0.5, 0.5)
  /// ```
  ///
  /// - Parameters:
  ///   - sx: The horizontal shear factor. Positive values shear to the right, negative to the left.
  ///        A value of 1 means 45 degrees of shear.
  ///   - sy: The vertical shear factor. Positive values shear downwards, negative upwards.
  ///        A value of 1 means 45 degrees of shear.
  /// - Returns: The shear transform.
  @inlinable
  @inline(__always)
  static func shear(_ sx: CGFloat, _ sy: CGFloat) -> CGAffineTransform {
    CGAffineTransform(a: 1, b: sy, c: sx, d: 1, tx: 0, ty: 0)
  }

  // TODO: add shear by degree

  // MARK: - Initializer

  /// Initializes a transform with a rotation angle.
  ///
  /// - Parameter angle: The rotation angle, clockwise rotation.
  init(rotationAngle angle: Angle) {
    self.init(rotationAngle: angle.radians)
  }

  // MARK: - Operations

  /// Inverts the transform.
  ///
  /// - Returns: The inverted transform.
  @inlinable
  @inline(__always)
  func invert() -> Self {
    inverted()
  }

  /// Translates the transform.
  ///
  /// Example:
  /// ```swift
  /// transform.translate(x: 10, y: 20)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the translation.
  ///   - y: The y-coordinate of the translation.
  /// - Returns: The translated transform.
  @inlinable
  @inline(__always)
  func translate(x tx: CGFloat = 0, y ty: CGFloat = 0) -> Self {
    translatedBy(x: tx, y: ty)
  }

  /// Translates the transform.
  ///
  /// Example:
  /// ```swift
  /// transform.translate(10, 20)
  /// ```
  ///
  /// - Parameters:
  ///   - tx: The x-coordinate of the translation.
  ///   - ty: The y-coordinate of the translation.
  /// - Returns: The translated transform.
  @inlinable
  @inline(__always)
  func translate(_ tx: CGFloat, _ ty: CGFloat) -> Self {
    translatedBy(x: tx, y: ty)
  }

  /// Scales the transform.
  ///
  /// Example:
  /// ```swift
  /// transform.scale(x: 10, y: 10)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the scale.
  ///   - y: The y-coordinate of the scale.
  /// - Returns: The scaled transform.
  @inlinable
  @inline(__always)
  func scale(x sx: CGFloat = 1, y sy: CGFloat = 1) -> Self {
    scaledBy(x: sx, y: sy)
  }

  /// Scales the transform.
  ///
  /// Example:
  /// ```swift
  /// transform.scale(10, 10)
  /// ```
  ///
  /// - Parameters:
  ///   - sx: The x-coordinate of the scale.
  ///   - sy: The y-coordinate of the scale.
  /// - Returns: The scaled transform.
  @inlinable
  @inline(__always)
  func scale(_ sx: CGFloat, _ sy: CGFloat) -> Self {
    scaledBy(x: sx, y: sy)
  }

  /// Rotates the transform by the given angle.
  ///
  /// Example:
  /// ```swift
  /// transform.rotate(.degrees(45))
  /// ```
  ///
  /// - Parameter angle: The rotation angle.
  /// - Returns: The rotated transform.
  @inlinable
  @inline(__always)
  func rotate(angle: Angle) -> CGAffineTransform {
    rotated(by: angle.radians)
  }

  /// Shears the transform.
  ///
  /// Example:
  /// ```swift
  /// transform.shear(x: 1, y: 0.5)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The horizontal shear factor. Positive values shear to the right, negative to the left.
  ///        A value of 1 means 45 degrees of shear.
  ///   - y: The vertical shear factor. Positive values shear downwards, negative upwards.
  ///        A value of 1 means 45 degrees of shear.
  /// - Returns: The sheared transform.
  @inlinable
  @inline(__always)
  func shear(x sx: CGFloat = 0, y sy: CGFloat = 0) -> Self {
    concat(.shear(sx, sy))
  }

  /// Shears the transform.
  ///
  /// Example:
  /// ```swift
  /// transform.shear(0.5, 0.5)
  /// ```
  ///
  /// - Parameters:0.5
  ///   - sx: The horizontal shear factor. Positive values shear to the right, negative to the left.
  ///        A value of 1 means 45 degrees of shear.
  ///   - sy: The vertical shear factor. Positive values shear downwards, negative upwards.
  ///        A value of 1 means 45 degrees of shear.
  /// - Returns: The sheared transform.
  @inlinable
  @inline(__always)
  func shear(_ sx: CGFloat, _ sy: CGFloat) -> Self {
    concat(.shear(sx, sy))
  }

  /// Concatenates two transforms.
  ///
  /// Example:
  /// ```swift
  /// transform.concat(CGAffineTransform.translation(10, 20))
  /// ```
  ///
  /// - Parameters:
  ///   - another: The transform to concatenate.
  /// - Returns: The concatenated transform.
  @inlinable
  @inline(__always)
  func concat(_ another: Self) -> Self {
    concatenating(another)
  }
}

// MARK: - Hashable

extension CoreGraphics.CGAffineTransform: Swift.Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(a)
    hasher.combine(b)
    hasher.combine(c)
    hasher.combine(d)
    hasher.combine(tx)
    hasher.combine(ty)
  }
}

// MARK: - ApproximatelyEquatable

extension CGAffineTransform: ApproximatelyEquatable {

  /// Check if the transform is approximately equal to another transform.
  ///
  /// - Parameters:
  ///   - other: The other transform.
  ///   - absoluteTolerance: The absolute tolerance.
  /// - Returns: `true` if the transform is approximately equal to the other transform.
  public func isApproximatelyEqual(to other: Self, absoluteTolerance: Double) -> Bool {
    a.isApproximatelyEqual(to: other.a, absoluteTolerance: absoluteTolerance) &&
      b.isApproximatelyEqual(to: other.b, absoluteTolerance: absoluteTolerance) &&
      c.isApproximatelyEqual(to: other.c, absoluteTolerance: absoluteTolerance) &&
      d.isApproximatelyEqual(to: other.d, absoluteTolerance: absoluteTolerance) &&
      tx.isApproximatelyEqual(to: other.tx, absoluteTolerance: absoluteTolerance) &&
      ty.isApproximatelyEqual(to: other.ty, absoluteTolerance: absoluteTolerance)
  }
}

// MARK: - Concatenation

public extension [CGAffineTransform] {

  /// Concatenates the transforms into a single transform.
  ///
  /// Example:
  /// ```swift
  /// [CGAffineTransform...].concatenated()
  /// ```
  ///
  /// - Returns: The concatenated transform.
  func concatenated() -> CGAffineTransform {
    guard !isEmpty else {
      return .identity
    }

    guard count > 1 else {
      return self[0]
    }

    return reduce(into: CGAffineTransform.identity) { result, next in
      result = result.concatenating(next)
    }
  }
}
