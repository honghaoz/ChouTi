//
//  CGRect+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2015-12-09.
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

// MARK: - Init

public extension CGRect {

  /// Create a rect with the given x, y, width, and height.
  ///
  /// - Parameters:
  ///   - x: The x value.
  ///   - y: The y value.
  ///   - width: The width value.
  ///   - height: The height value.
  @inlinable
  @inline(__always)
  init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
    self.init(x: x, y: y, width: width, height: height)
  }

  /// Create a rect with the given origin and size.
  ///
  /// - Parameters:
  ///   - origin: The origin value.
  ///   - size: The size value.
  @inlinable
  @inline(__always)
  init(_ origin: CGPoint, _ size: CGSize) {
    self.init(origin: origin, size: size)
  }

  /// Create a rect with the given origin and size.
  ///
  /// - Parameters:
  ///   - origin: The origin value.
  ///   - size: The size value.
  @inlinable
  @inline(__always)
  init(_ origin: CGPoint, _ size: CGFloat) {
    self.init(origin: origin, size: CGSize(size))
  }

  /// Create a rect with the given size. The origin is set to (0, 0).
  ///
  /// - Parameters:
  ///   - size: The size value.
  @inlinable
  @inline(__always)
  init(size: CGSize) {
    self.init(origin: .zero, size: size)
  }

  /// Create a rect with the given size. The origin is set to (0, 0).
  ///
  /// - Parameters:
  ///   - size: The size value.
  @inlinable
  @inline(__always)
  init(_ size: CGSize) {
    self.init(origin: .zero, size: size)
  }

  /// Create a rect with top left corner point and bottom right corner point.
  ///
  /// - Parameters:
  ///   - topLeft: The top left point
  ///   - bottomRight: The bottom right point.
  init(topLeft: CGPoint, bottomRight: CGPoint) {
    ChouTi.assert(bottomRight.x >= topLeft.x)
    ChouTi.assert(bottomRight.y >= topLeft.y)
    self.init(topLeft, CGSize(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y))
  }
}

// MARK: - Geometry

public extension CGRect {

  /// The rectangle's origin x value.
  @inlinable
  @inline(__always)
  var x: CGFloat {
    get { origin.x }
    set { origin.x = newValue }
  }

  /// The rectangle's origin y value.
  @inlinable
  @inline(__always)
  var y: CGFloat {
    get { origin.y }
    set { origin.y = newValue }
  }

  /// The rectangle's vertical top Y value. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var top: CGFloat {
    get { minY }
    set { origin.y = newValue }
  }

  /// The rectangle's vertical bottom Y value. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var bottom: CGFloat {
    get { maxY }
    set { origin.y = newValue - height }
  }

  /// The rectangle's left X value.
  @inlinable
  @inline(__always)
  var left: CGFloat {
    get { x }
    set { x = newValue }
  }

  /// The rectangle's right X value.
  @inlinable
  @inline(__always)
  var right: CGFloat {
    get { x + width }
    set { origin.x = newValue - width }
  }

  /// The rectangle's top left corner point. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var topLeft: CGPoint {
    CGPoint(x: minX, y: minY)
  }

  /// The rectangle's top center point. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var topCenter: CGPoint {
    CGPoint(x: midX, y: minY)
  }

  /// The rectangle's top right corner point. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var topRight: CGPoint {
    CGPoint(x: maxX, y: minY)
  }

  /// The rectangle's bottom left corner point. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var bottomLeft: CGPoint {
    CGPoint(x: minX, y: maxY)
  }

  /// The rectangle's bottom center point. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var bottomCenter: CGPoint {
    CGPoint(x: midX, y: maxY)
  }

  /// The rectangle's bottom right corner point. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  @inlinable
  @inline(__always)
  var bottomRight: CGPoint {
    CGPoint(x: maxX, y: maxY)
  }

  /// The rectangle's left center point.
  @inlinable
  @inline(__always)
  var leftCenter: CGPoint {
    CGPoint(x: minX, y: midY)
  }

  /// The rectangle's right center point.
  @inlinable
  @inline(__always)
  var rightCenter: CGPoint {
    CGPoint(x: maxX, y: midY)
  }

  /// The rectangle's center point.
  ///
  /// - Note: This value doesn't respect the anchor point. It assumes the anchor point is (0.5, 0.5).
  var center: CGPoint {
    get { CGPoint(x: midX, y: midY) }
    set { origin = CGPoint(x: newValue.x - size.width / 2, y: newValue.y - size.height / 2) }
  }

  /// Returns a flipped rectangle within the container frame.
  ///
  /// - Note: This is useful for converting between different coordinate systems, i.e. flipping the frame on macOS.
  ///
  /// Example:
  /// ```
  /// // convert bottom-left origin to top-left origin based on the main screen coordinates
  /// externalScreen.frame.flipped(containerHeight: primaryScreen().frame.height)
  /// ```
  ///
  /// - Parameters:
  ///   - containerHeight: The height of the container.
  /// - Returns: A flipped `CGRect`.
  func flipped(containerHeight: CGFloat) -> CGRect {
    CGRect(x, containerHeight - y - height, width, height)
  }
}

// MARK: - Modification

public extension CGRect {

  /// Get a new `CGRect` with new origin.
  ///
  /// - Parameters:
  ///   - newOrigin: The new origin value.
  /// - Returns: A new `CGRect` with new origin.
  @inlinable
  @inline(__always)
  func origin(_ newOrigin: CGPoint) -> CGRect {
    CGRect(origin: newOrigin, size: size)
  }

  /// Get a new `CGRect` with new origin.x.
  ///
  /// - Parameters:
  ///   - newOriginX: The new origin.x value.
  /// - Returns: A new `CGRect` with new origin.x.
  @inlinable
  @inline(__always)
  func x(_ newOriginX: CGFloat) -> CGRect {
    CGRect(origin: CGPoint(newOriginX, y), size: size)
  }

  /// Get a new `CGRect` with new origin.y.
  ///
  /// - Parameters:
  ///   - newOriginY: The new origin.y value.
  /// - Returns: A new `CGRect` with new origin.y.
  @inlinable
  @inline(__always)
  func y(_ newOriginY: CGFloat) -> CGRect {
    CGRect(origin: CGPoint(x, newOriginY), size: size)
  }

  /// Get a new `CGRect` with new size.
  ///
  /// - Parameters:
  ///   - newSize: The new size value.
  /// - Returns: A new `CGRect` with new size.
  @inlinable
  @inline(__always)
  func size(_ newSize: CGSize) -> CGRect {
    CGRect(origin: origin, size: newSize)
  }

  /// Get a new `CGRect` with new width.
  ///
  /// - Parameters:
  ///   - newWidth: The new width value.
  /// - Returns: A new `CGRect` with new width.
  @inlinable
  @inline(__always)
  func width(_ newWidth: CGFloat) -> CGRect {
    CGRect(origin: origin, size: CGSize(newWidth, height))
  }

  /// Get a new `CGRect` with new height.
  ///
  /// - Parameters:
  ///   - newHeight: The new height value.
  /// - Returns: A new `CGRect` with new height.
  @inlinable
  @inline(__always)
  func height(_ newHeight: CGFloat) -> CGRect {
    CGRect(origin: origin, size: CGSize(width, newHeight))
  }
}

// MARK: - Inset & Expand

public extension CGRect {

  /// Inset the rectangle by the given amount.
  ///
  /// - Parameter amount: The amount to inset.
  /// - Returns: A new `CGRect` with inset.
  @inlinable
  @inline(__always)
  func inset(by amount: CGFloat) -> CGRect {
    insetBy(dx: amount, dy: amount)
  }

  /// Inset the rectangle by the given amount. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  ///
  /// - Parameters:
  ///   - left: The left inset amount.
  ///   - right: The right inset amount.
  ///   - top: The top inset amount.
  ///   - bottom: The bottom inset amount.
  /// - Returns: A new `CGRect` with inset.
  @inlinable
  @inline(__always)
  func inset(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) -> CGRect {
    CGRect(x: x + left, y: y + top, width: width - left - right, height: height - top - bottom)
  }

  /// Expand the rectangle by the given amount.
  ///
  /// - Parameter amount: The amount to expand.
  /// - Returns: A new `CGRect` with expanded.
  @inlinable
  @inline(__always)
  func expanded(by amount: CGFloat) -> CGRect {
    insetBy(dx: -amount, dy: -amount)
  }

  /// Expand the rectangle by the given amount. It assumes the origin is at the top left corner.
  ///
  /// - Note: on macOS, set `isFlipped` to true for NSView to make the coordinate system match UIKit.
  ///
  /// - Parameters:
  ///   - left: The left expand amount.
  ///   - right: The right expand amount.
  ///   - top: The top expand amount.
  ///   - bottom: The bottom expand amount.
  /// - Returns: A new `CGRect` with expanded.
  @inlinable
  @inline(__always)
  func expanded(left: CGFloat = 0, right: CGFloat = 0, top: CGFloat = 0, bottom: CGFloat = 0) -> CGRect {
    inset(left: -left, right: -right, top: -top, bottom: -bottom)
  }
}

// MARK: - Translate

public extension CGRect {

  /// Move/translate the rectangle.
  ///
  /// - Parameters:
  ///   - dx: The delta x.
  ///   - dy: The delta y.
  /// - Returns: A new `CGRect` with moved origin.
  @inlinable
  @inline(__always)
  func translate(dx: CGFloat = 0, dy: CGFloat = 0) -> CGRect {
    CGRect(origin: origin.translate(dx: dx, dy: dy), size: size)
  }

  /// Move/translate the rectangle.
  ///
  /// - Parameters:
  ///   - vector: The translation vector.
  /// - Returns: A new `CGRect` with moved origin.
  @inlinable
  @inline(__always)
  func translate(_ vector: CGVector) -> CGRect {
    CGRect(origin: origin.translate(dx: vector.dx, dy: vector.dy), size: size)
  }

  /// Move/translate the rectangle.
  ///
  /// - Parameters:
  ///   - point: The translation point.
  /// - Returns: A new `CGRect` with moved origin.
  @inlinable
  @inline(__always)
  func translate(_ point: CGPoint) -> CGRect {
    CGRect(origin: origin.translate(dx: point.x, dy: point.y), size: size)
  }
}

// MARK: - Scale

public extension CGRect {

  static func * (left: CGRect, _ scale: CGFloat) -> CGRect {
    return CGRect(x: left.origin.x * scale, y: left.origin.y * scale, width: left.size.width * scale, height: left.size.height * scale)
  }

  static func *= (left: inout CGRect, _ scale: CGFloat) {
    left = left * scale
  }
}

// MARK: - Pixel Perfect

public extension CGRect {

  /// Returns the smallest rectangle that results from converting the source rectangle values to nearest pixel.
  ///
  /// - Parameter scaleFactor: The scale factor. Usually, this is the screen scale factor (e.g. `UIScreen.main.scale`).
  /// - Returns: A pixel perfect `CGRect`.
  func rounded(scaleFactor: CGFloat) -> CGRect {
    if isNull || isInfinite {
      return self
    }

    let pixelWidth: CGFloat = 1 / scaleFactor

    /**
     From `CGRect.integral`:
     A rectangle with the smallest integer values for its origin and size that contains the source rectangle.
     That is, given a rectangle with fractional origin or size values,
     integral rounds the rectangle’s origin downward
     and its size upward to the nearest whole integers,
     such that the result contains the original rectangle.
     Returns a null rectangle if rect is a null rectangle.

     ChouTi note:
     It doesn't make sense to round to integers as modern iPhone screens has 3x scale factor.
     It makes sense to round to the nearest pixel.
     So the rounding logic is, given a rectangle with fractional origin or size values,
     rounds the rectangle’s origin to the nearest whole pixel,
     rounds the rectangle’s size to the nearest whole pixel.
     So that it gives the rectangle a size as close as to the pixel boundary.
     */
    let x = x.round(nearest: pixelWidth)
    let y = y.round(nearest: pixelWidth)
    let width = width.round(nearest: pixelWidth)
    let height = height.round(nearest: pixelWidth)
    return CGRect(x: x, y: y, width: width, height: height)

    /// Other readings:
    /// - https://tanalin.com/en/articles/integer-scaling/
    /// - https://github.com/facebook/yoga/blob/578d197dd6652225b46af090c0b46471dc887361/yoga/Yoga.cpp#L3622
  }
}

// MARK: - Interpolation

public extension CGRect {

  /// Linear interpolation between self and another rectangle.
  ///
  /// Rectangles are interpolated by their origin and size.
  ///
  /// - Parameters:
  ///   - end: The end `CGRect`.
  ///   - t: The interpolation progress. The value is clamped to `0 ... 1`.
  /// - Returns: An interpolated `CGRect`.
  func lerp(to end: CGRect, t: Double) -> CGRect {
    let progress = t.clamped(to: 0 ... 1)
    let x = x + (end.x - x) * progress
    let y = y + (end.y - y) * progress
    let width = width + (end.width - width) * progress
    let height = height + (end.height - height) * progress
    return CGRect(x, y, width, height)
  }
}

// MARK: - Intersection

public extension CGRect {

  /// Returns `true` if two rects intersects or touches, even if only edge or corner touches.
  ///
  /// The standard `intersects(_:)` has undefined behavior when two rects have touching edges or points.
  ///
  /// - Parameters:
  ///   - rect2: The other rect.
  /// - Returns: `true` if two rects intersects, otherwise `false`.
  func intersects2(_ rect2: CGRect) -> Bool {
    if isNull || rect2.isNull {
      return false
    }

    if isInfinite || rect2.isInfinite {
      return true
    }

    /// https://leetcode.com/problems/rectangle-overlap/
    /// https://leetcode.com/problems/rectangle-overlap/solution/

    /**
      The answer for whether they don't overlap is LEFT OR RIGHT OR UP OR DOWN,
      where OR is the logical OR,
      and LEFT is a boolean that represents whether rect1 is to the left of rect2.
      The answer for whether they do overlap is the negation of this.

       ┌──────────────┐
       │              │ ┌──────────────┐
       │    Rect1     │ │              │
       │              │ │    Rect2     │
       └──────────────┘ │              │
                        └──────────────┘

      ───────────────────────────────────────

       ┌──────────────┐
       │              │
       │    Rect1     │
       │              │
       └──────────────┘
             ┌──────────────┐
             │              │
             │    Rect2     │
             │              │
             └──────────────┘

      ───────────────────────────────────────

                        ┌──────────────┐
       ┌──────────────┐ │              │
       │              │ │    Rect1     │
       │    Rect2     │ │              │
       │              │ └──────────────┘
       └──────────────┘

      ───────────────────────────────────────

       ┌──────────────┐
       │              │
       │    Rect2     │
       │              │
       └──────────────┘
           ┌──────────────┐
           │              │
           │    Rect1     │
           │              │
           └──────────────┘
     */

    return !(
      maxX < rect2.minX || // left
        maxY < rect2.minY || // top
        minX > rect2.maxX || // right
        minY > rect2.maxY // bottom
    )

    // Alternative:
    /**
      If the rectangles overlap, they have positive area.
      This area must be a rectangle where both dimensions are positive, since the boundaries of the intersection are axis aligned.
      Thus, we can reduce the problem to the one-dimensional problem of determining whether two line segments overlap.

      ■───────────●

                     ■───────────●

      when overlaps, the smaller of ● is > the larger of ■
     */

    // return (min(maxX, rect2.maxX) >= max(minX, rect2.minX)) &&
    //   (min(maxY, rect2.maxY) >= max(minY, rect2.minY))
  }

  /// Returns the intersection of two rectangles.
  ///
  /// Returns a non-nil `CGRect` when the intersection rect is valid and not empty.
  ///
  /// - Parameter rect2: The other rect.
  /// - Returns: A `CGRect` instance if has non-empty intersection, otherwise, returns `nil`.
  func nonEmptyIntersection(_ rect2: CGRect) -> CGRect? {
    let intersection = intersection(rect2)
    guard !intersection.isNull, !intersection.isEmpty else {
      return nil
    }

    return intersection
  }

  /// Returns the intersection of two rectangles.
  ///
  /// - Parameter rect2: The other rect.
  /// - Returns: A `CGRect` instance if has non-empty intersection, otherwise, returns `nil`.
  func intersection2(_ rect2: CGRect) -> CGRect {
    /// https://forums.swift.org/t/cgrect-intersection-gives-surprising-result-due-to-floating-point-arithmetic/21336
    /// https://github.com/lovasoa/rectangle-overlap/blob/master/index.ts

    if isNull || rect2.isNull {
      return .null
    }

    if isInfinite {
      return rect2
    } else if rect2.isInfinite {
      return self
    }

    /**

        min(rect1.maxX, rect2.maxX)
                      │
                      │
                      ▼

          ■───────────●

                    ■───────────●

                    ▲
                    │
                    │
      max(rect1.minX, rect2.minX)

     */
    let x = max(minX, rect2.minX)
    let y = max(minY, rect2.minY)

    let width = min(maxX, rect2.maxX) - x
    if width < 0 {
      return .null
    }

    let height = min(maxY, rect2.maxY) - y
    if height < 0 {
      return .null
    }

    return CGRect(x: x, y: y, width: width, height: height)
  }

  /// Returns `true` if `self` fully contains `rect`.
  func approximatelyContains(_ rect: CGRect, absoluteTolerance: CGFloat) -> Bool {
    nonEmptyIntersection(rect)?.isApproximatelyEqual(to: rect, absoluteTolerance: absoluteTolerance) == true
  }
}

// MARK: - Misc

public extension CGRect {

  /// Returns the center aligned square rect within the rectangle.
  func squareRect() -> CGRect {
    let squareSize = min(width, height)
    return CGRect((width - squareSize) / 2, (height - squareSize) / 2, squareSize, squareSize)
  }

  /// Returns the aspect ratio (width / height).
  ///
  /// - Note: This will return `greatestFiniteMagnitude` if height is zero.
  @inlinable
  @inline(__always)
  var aspectRatio: CGFloat {
    size.aspectRatio
  }

  /// Returns `true` if the rectangle is a portrait rectangle.
  ///
  /// Square shape is counted as portrait.
  @inlinable
  @inline(__always)
  var isPortrait: Bool {
    size.isPortrait
  }

  /// Returns `true` if the rectangle is a landscape rectangle.
  ///
  /// Square shape is **NOT** counted as landscape.
  @inlinable
  @inline(__always)
  var isLandScape: Bool {
    size.isLandScape
  }

  /// Returns `true` if the rectangle is a square.
  ///
  /// Zero sized rectangle is also counted as square.
  var isSquare: Bool {
    if self == .infinite {
      return false
    }
    return size.isSquare
  }
}

public extension CGRect {

  /// Returns `true` if `self` is approximately equal to another rectangle.
  ///
  /// - Parameters:
  ///   - other: The other rectangle.
  ///   - absoluteTolerance: The absolute tolerance.
  /// - Returns: `true` if `self` is approximately equal to another rectangle, otherwise `false`.
  @inlinable
  @inline(__always)
  func isApproximatelyEqual(to other: Self, absoluteTolerance: CGFloat) -> Bool {
    origin.isApproximatelyEqual(to: other.origin, absoluteTolerance: absoluteTolerance) &&
      size.isApproximatelyEqual(to: other.size, absoluteTolerance: absoluteTolerance)
  }
}

// MARK: - Hashable

extension CGRect: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(origin.x)
    hasher.combine(origin.y)
    hasher.combine(size.width)
    hasher.combine(size.height)
  }
}
