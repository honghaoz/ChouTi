//
//  CATransform3D+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/21/21.
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

#if canImport(QuartzCore)
import QuartzCore

public extension CATransform3D {

  // MARK: - Conversion

  /// Convert to a CGAffineTransform.
  @inlinable
  @inline(__always)
  var affineTransform: CGAffineTransform {
    // https://www.youtube.com/watch?v=E3Phj6J287o
    CATransform3DGetAffineTransform(self)
  }

  // MARK: - Check

  /// Returns `true` if `self` is identity transform.
  @inlinable
  @inline(__always)
  var isIdentity: Bool {
    CATransform3DIsIdentity(self)
  }

  /// Returns `true` if `self` is affine transform.
  @inlinable
  @inline(__always)
  var isAffine: Bool {
    CATransform3DIsAffine(self)
  }

  // MARK: - Static

  /// The identity transform.
  static let identity = CATransform3DIdentity

  /// The zero transform.
  static let zero = CATransform3D(m11: 0, m12: 0, m13: 0, m14: 0, m21: 0, m22: 0, m23: 0, m24: 0, m31: 0, m32: 0, m33: 0, m34: 0, m41: 0, m42: 0, m43: 0, m44: 0)

  /// The horizontal flip transform.
  static let horizontalFlip = CATransform3D(m11: -1, m12: 0, m13: 0, m14: 0, m21: 0, m22: 1, m23: 0, m24: 0, m31: 0, m32: 0, m33: 1, m34: 0, m41: 0, m42: 0, m43: 0, m44: 1)

  /// The vertical flip transform.
  static let verticalFlip = CATransform3D(m11: 1, m12: 0, m13: 0, m14: 0, m21: 0, m22: -1, m23: 0, m24: 0, m31: 0, m32: 0, m33: 1, m34: 0, m41: 0, m42: 0, m43: 0, m44: 1)

  // MARK: - Factory

  // MARK: - Translation

  /// Creates a translation transform.
  ///
  /// Example:
  /// ```swift
  /// CATransform3D.translation(x: 10, y: 20, z: 30)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the translation.
  ///   - y: The y-coordinate of the translation.
  ///   - z: The z-coordinate of the translation.
  /// - Returns: The translation transform.
  @inlinable
  @inline(__always)
  static func translation(x tx: CGFloat = 0, y ty: CGFloat = 0, z tz: CGFloat = 0) -> Self {
    CATransform3DMakeTranslation(tx, ty, tz)
  }

  /// Creates a translation transform.
  ///
  /// Example:
  /// ```swift
  /// CATransform3D.translation(10, 20, 30)
  /// ```
  ///
  /// - Parameters:
  ///   - tx: The x-coordinate of the translation.
  ///   - ty: The y-coordinate of the translation.
  ///   - tz: The z-coordinate of the translation.
  /// - Returns: The translation transform.
  @inlinable
  @inline(__always)
  static func translation(_ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> Self {
    CATransform3DMakeTranslation(tx, ty, tz)
  }

  // MARK: - Scale

  /// Creates a scale transform.
  ///
  /// Example:
  /// ```swift
  /// CATransform3D.scale(x: 10, y: 10, z: 10)
  /// ```
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the scale.
  ///   - y: The y-coordinate of the scale.
  ///   - z: The z-coordinate of the scale.
  /// - Returns: The scale transform.
  @inlinable
  @inline(__always)
  static func scale(x sx: CGFloat = 0, y sy: CGFloat = 0, z sz: CGFloat = 0) -> Self {
    CATransform3DMakeScale(sx, sy, sz)
  }

  /// Creates a scale transform.
  ///
  /// Example:
  /// ```swift
  /// CATransform3D.scale(10, 10, 10)
  /// ```
  ///
  /// - Parameters:
  ///   - sx: The x-coordinate of the scale.
  ///   - sy: The y-coordinate of the scale.
  ///   - sz: The z-coordinate of the scale.
  /// - Returns: The scale transform.
  @inlinable
  @inline(__always)
  static func scale(_ sx: CGFloat, _ sy: CGFloat, _ sz: CGFloat) -> Self {
    CATransform3DMakeScale(sx, sy, sz)
  }

  // MARK: - Rotation

  /// The axis of rotation.
  enum Axis {
    case x
    case y
    case z
  }

  /// Creates a rotation transform matrix around an axis in clockwise direction.
  ///
  /// Examples:
  /// ```
  /// // rotate by 30 degrees around z axis in clockwise direction.
  /// .rotation(angle: .radians(30), axis: .z)
  /// ```
  ///
  /// - Parameters:
  ///   - angle: The rotation angle.
  ///   - axis: The axis to rotate.
  /// - Returns: A rotation transform.
  @inlinable
  @inline(__always)
  static func rotation(angle: Angle, axis: Axis) -> Self {
    CATransform3DMakeRotation(angle.radians, axis == .x ? 1 : 0, axis == .y ? 1 : 0, axis == .z ? 1 : 0)
  }

  /// Creates a rotation transform matrix in clockwise direction about the vector `(x, y, z)`.
  ///
  /// - x and y axis is same as 2D rotation.
  /// - z axis is perpendicular towards you.
  ///
  /// Examples:
  /// ```
  /// // rotate by 30 degrees around z axis in clockwise direction.
  /// .rotation(angle: .radians(30), x: 1, y: 0, z: 0)
  /// ```
  ///
  /// - Parameters:
  ///   - angle: The rotation angle.
  ///   - x: The x-coordinate of the rotation vector.
  ///   - y: The y-coordinate of the rotation vector.
  ///   - z: The z-coordinate of the rotation vector.
  /// - Returns: A rotation transform.
  @inlinable
  @inline(__always)
  static func rotation(angle: Angle, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> Self {
    CATransform3DMakeRotation(angle.radians, x, y, z)
  }

  /// Creates a rotation transform matrix in clockwise direction about the vector `(x, y, z)`.
  ///
  /// - x and y axis is same as 2D rotation.
  /// - z axis is perpendicular towards you.
  ///
  /// Examples:
  /// ```
  /// // rotate by 30 degrees around z axis in clockwise direction.
  /// .rotation(.radians(30), 1, 0, 0)
  /// ```
  ///
  /// - Parameters:
  ///   - angle: The rotation angle.
  ///   - x: The x-coordinate of the rotation vector.
  ///   - y: The y-coordinate of the rotation vector.
  ///   - z: The z-coordinate of the rotation vector.
  /// - Returns: A rotation transform.
  @inlinable
  @inline(__always)
  static func rotation(_ angle: Angle, _ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> Self {
    CATransform3DMakeRotation(angle.radians, x, y, z)
  }

  // MARK: - Affine Transform

  /// Creates a transform with the same effect as affine transform.
  ///
  /// - Parameters:
  ///   - m: The affine transform.
  /// - Returns: The transform.
  @inlinable
  @inline(__always)
  static func affineTransform(_ m: CGAffineTransform) -> Self {
    CATransform3DMakeAffineTransform(m)
  }

  // MARK: - Operations

  /// Inverts the transform.
  ///
  /// - Returns: The inverted transform.
  @inlinable
  @inline(__always)
  func invert() -> Self {
    CATransform3DInvert(self)
  }

  /// Translates the transform.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the translation.
  ///   - y: The y-coordinate of the translation.
  ///   - z: The z-coordinate of the translation.
  /// - Returns: The translated transform.
  @inlinable
  @inline(__always)
  func translate(x tx: CGFloat = 0, y ty: CGFloat = 0, z tz: CGFloat = 0) -> Self {
    CATransform3DTranslate(self, tx, ty, tz)
  }

  /// Translates the transform.
  ///
  /// - Parameters:
  ///   - tx: The x-coordinate of the translation.
  ///   - ty: The y-coordinate of the translation.
  ///   - tz: The z-coordinate of the translation.
  /// - Returns: The translated transform.
  @inlinable
  @inline(__always)
  func translate(_ tx: CGFloat, _ ty: CGFloat, _ tz: CGFloat) -> Self {
    CATransform3DTranslate(self, tx, ty, tz)
  }

  /// Scales the transform.
  ///
  /// - Parameters:
  ///   - x: The x-coordinate of the scale.
  ///   - y: The y-coordinate of the scale.
  ///   - z: The z-coordinate of the scale.
  /// - Returns: The scaled transform.
  @inlinable
  @inline(__always)
  func scale(x sx: CGFloat = 1, y sy: CGFloat = 1, z sz: CGFloat = 1) -> Self {
    CATransform3DScale(self, sx, sy, sz)
  }

  /// Scales the transform.
  ///
  /// - Parameters:
  ///   - sx: The x-coordinate of the scale.
  ///   - sy: The y-coordinate of the scale.
  ///   - sz: The z-coordinate of the scale.
  /// - Returns: The scaled transform.
  @inlinable
  @inline(__always)
  func scale(_ sx: CGFloat, _ sy: CGFloat, _ sz: CGFloat) -> Self {
    CATransform3DScale(self, sx, sy, sz)
  }

  /// Rotates the transform around an axis in clockwise direction.
  ///
  /// - Parameters:
  ///   - angle: The rotation angle.
  ///   - axis: The axis to rotate.
  /// - Returns: The rotated transform.
  @inlinable
  @inline(__always)
  func rotate(angle: Angle, axis: Axis) -> Self {
    CATransform3DRotate(self, angle.radians, axis == .x ? 1 : 0, axis == .y ? 1 : 0, axis == .z ? 1 : 0)
  }

  /// Rotates the transform in clockwise direction about a vector `(x, y, z)`.
  ///
  /// - Parameters:
  ///   - angle: The rotation angle.
  ///   - x: The x-coordinate of the rotation vector.
  ///   - y: The y-coordinate of the rotation vector.
  ///   - z: The z-coordinate of the rotation vector.
  /// - Returns: The rotated transform.
  @inlinable
  @inline(__always)
  func rotate(angle: Angle, x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) -> Self {
    CATransform3DRotate(self, angle.radians, x, y, z)
  }

  /// Rotates the transform in clockwise direction about a vector `(x, y, z)`.
  ///
  /// - Parameters:
  ///   - angle: The rotation angle.
  ///   - x: The x-coordinate of the rotation vector.
  ///   - y: The y-coordinate of the rotation vector.
  ///   - z: The z-coordinate of the rotation vector.
  /// - Returns: The rotated transform.
  @inlinable
  @inline(__always)
  func rotate(_ angle: Angle, _ x: CGFloat, _ y: CGFloat, _ z: CGFloat) -> Self {
    CATransform3DRotate(self, angle.radians, x, y, z)
  }

  /// Concatenates two transforms.
  ///
  /// - Parameters:
  ///   - another: The transform to concatenate.
  /// - Returns: The concatenated transform.
  @inlinable
  @inline(__always)
  func concat(_ another: CATransform3D) -> Self {
    CATransform3DConcat(self, another)
  }
}

// MARK: - Hashable

extension QuartzCore.CATransform3D: Swift.Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(m11)
    hasher.combine(m12)
    hasher.combine(m13)
    hasher.combine(m14)
    hasher.combine(m21)
    hasher.combine(m22)
    hasher.combine(m23)
    hasher.combine(m24)
    hasher.combine(m31)
    hasher.combine(m32)
    hasher.combine(m33)
    hasher.combine(m34)
    hasher.combine(m41)
    hasher.combine(m42)
    hasher.combine(m43)
    hasher.combine(m44)
  }
}

// MARK: - Equatable

extension QuartzCore.CATransform3D: Swift.Equatable {

  public static func == (lhs: CATransform3D, rhs: CATransform3D) -> Bool {
    CATransform3DEqualToTransform(lhs, rhs)
  }
}

// MARK: - Concatenation

public extension [CATransform3D] {

  /// Concatenates the transforms into a single transform.
  ///
  /// Example:
  /// ```swift
  /// [CATransform3D...].concatenated()
  /// ```
  ///
  /// - Returns: The concatenated transform.
  func concatenated() -> CATransform3D {
    switch count {
    case 0:
      return CATransform3DIdentity
    case 1:
      return self[0]
    default:
      return reduce(CATransform3DIdentity, CATransform3DConcat)
    }
  }
}

#endif

/**
 3D Animations
 http://www.sunsetlakesoftware.com/2008/10/22/3-d-rotation-without-trackball
 */

/// https://articulatedrobotics.xyz/tutorials/coordinate-transforms/rotations-3d/
