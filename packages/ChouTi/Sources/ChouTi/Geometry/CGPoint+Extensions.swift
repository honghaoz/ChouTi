//
//  CGPoint+Extensions.swift
//
//  Created by Honghao Zhang on 2019-07-11.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import CoreGraphics

public extension CGPoint {

  /// Initialize a point with x and y.
  ///
  /// - Parameters:
  ///   - x: The x coordinate.
  ///   - y: The y coordinate.
  @inlinable
  @inline(__always)
  init(_ x: CGFloat, _ y: CGFloat) {
    self.init(x: x, y: y)
  }

  /// Get the midpoint between two points.
  ///
  /// Example:
  /// ```
  /// let p1 = CGPoint(x: 10, y: 20)
  /// let p2 = CGPoint(x: 100, y: 50)
  /// let midPoint = CGPoint.midPoint(p1: p1, p2: p2)
  /// print(midPoint) // CGPoint(x: 55, y: 35)
  /// ```
  ///
  /// - Parameters:
  ///   - p1: The first point.
  ///   - p2: The second point.
  /// - Returns: The midpoint between the two points.
  static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
    CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
  }

  /// Translate the point.
  ///
  /// Example:
  /// ```
  /// let point = CGPoint(x: 10, y: 20)
  /// let translatedPoint = point.translate(dx: 5, dy: 10)
  /// print(translatedPoint) // CGPoint(x: 15, y: 30)
  /// ```
  ///
  /// - Parameters:
  ///   - dx: The delta x.
  ///   - dy: The delta y.
  /// - Returns: The translated point.
  @inlinable
  @inline(__always)
  func translate(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
    CGPoint(x: x + dx, y: y + dy)
  }

  /// Translate the point by a vector.
  ///
  /// Example:
  /// ```
  /// let point = CGPoint(x: 10, y: 20)
  /// let translatedPoint = point.translate(vector: CGVector(dx: 5, dy: 10))
  /// print(translatedPoint) // CGPoint(x: 15, y: 30)
  /// ```
  ///
  /// - Parameters:
  ///   - vector: The vector to translate the point.
  /// - Returns: The translated point.
  @inlinable
  @inline(__always)
  func translate(_ vector: CGVector) -> CGPoint {
    CGPoint(x: x + vector.dx, y: y + vector.dy)
  }

  /// Translate the point by a point.
  ///
  /// Example:
  /// ```
  /// let point = CGPoint(x: 10, y: 20)
  /// let translatedPoint = point.translate(point: CGPoint(x: 5, y: 10))
  /// print(translatedPoint) // CGPoint(x: 15, y: 30)
  /// ```
  ///
  /// - Parameters:
  ///   - point: The point to translate the point.
  /// - Returns: The translated point.
  @inlinable
  @inline(__always)
  func translate(_ point: CGPoint) -> CGPoint {
    CGPoint(x: x + point.x, y: y + point.y)
  }

  /// Get the distance between two points.
  ///
  /// Example:
  /// ```
  /// let p1 = CGPoint(x: 0, y: 0)
  /// let p2 = CGPoint(x: 50, y: 50)
  /// let distance = p1.distance(to: p2)
  /// print(distance) // 70.71067811865476
  /// ```
  ///
  /// - Parameters:
  ///   - otherPoint: The other point.
  /// - Returns: The distance between the two points.
  func distance(to otherPoint: CGPoint) -> CGFloat {
    let xDelta = x - otherPoint.x
    let yDelta = y - otherPoint.y
    return ((xDelta * xDelta) + (yDelta * yDelta)).squareRoot()
  }

  /// Linear interpolate between self and another point.
  ///
  /// - Parameters:
  ///   - endPoint: The end point.
  ///   - t: The interpolation value between the two points. The value is clamped to the range [0, 1].
  /// - Returns: The interpolated point between the two points.
  func lerp(endPoint: CGPoint, t: Double) -> CGPoint {
    CGPoint(
      ChouTi.lerp(start: x, end: endPoint.x, t: CGFloat(t)),
      ChouTi.lerp(start: y, end: endPoint.y, t: CGFloat(t))
    )
  }

  static prefix func - (value: Self) -> Self {
    Self(-value.x, -value.y)
  }

  static func + (left: Self, right: Self) -> Self {
    Self(left.x + right.x, left.y + right.y)
  }

  /// Get a vector from left to right.
  static func - (left: Self, right: Self) -> Self {
    Self(left.x - right.x, left.y - right.y)
  }

  static func * (left: CGPoint, _ scale: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * scale, y: left.y * scale)
  }

  static func *= (left: inout CGPoint, _ scale: CGFloat) {
    left = left * scale
  }

  /// Get a flipped point within the container frame.
  ///
  /// - Parameters:
  ///   - containerHeight: The height of the container.
  /// - Returns: The flipped point.
  @inlinable
  @inline(__always)
  func flipped(containerHeight: CGFloat) -> CGPoint {
    CGPoint(x, containerHeight - y)
  }

  /// Convert the point to a vector.
  ///
  /// - Returns: The vector.
  @inlinable
  @inline(__always)
  func asVector() -> CGVector {
    CGVector(dx: x, dy: y)
  }
}

public extension CGPoint {

  /// Check if the point is approximately equal to another point.
  ///
  /// - Parameters:
  ///   - other: The other point.
  ///   - absoluteTolerance: The absolute tolerance.
  /// - Returns: `true` if the point is approximately equal to the other point.
  @inlinable
  @inline(__always)
  func isApproximatelyEqual(to other: Self, absoluteTolerance: CGFloat) -> Bool {
    x.isApproximatelyEqual(to: other.x, absoluteTolerance: absoluteTolerance) &&
      y.isApproximatelyEqual(to: other.y, absoluteTolerance: absoluteTolerance)
  }
}

// MARK: - Hashable

extension CGPoint: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
}
