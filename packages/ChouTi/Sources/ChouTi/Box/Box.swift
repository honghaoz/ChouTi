//
//  Box.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import CoreGraphics
import Foundation

/// A `class` type wrapper box that can hold any value.
///
/// This is a reference type so that you can use it in a `struct` to update
/// the underlying value without making the `struct` as `mutating``.
public final class Box<T> {

  /// The value wrapped in the box.
  public var value: T

  /// Create a box with a value.
  /// - Parameter value: The value to be wrapped.
  public init(value: T) {
    self.value = value
  }

  /// Create a box with a value.
  /// - Parameter value: The value to be wrapped.
  public init(_ value: T) {
    self.value = value
  }
}

/// A protocol that allows any type to be wrapped in a `Box`.
public protocol BoxWrapping {

  /// Wrap `self` in a `Box`.
  /// - Returns: A `Box` that wraps `self`.
  func wrapInBox() -> Box<Self>
}

// BoxWrapping default implementation
public extension BoxWrapping {

  func wrapInBox() -> Box<Self> {
    Box(self)
  }
}

extension String: BoxWrapping {}
extension Int: BoxWrapping {}
extension CGFloat: BoxWrapping {}
extension Float: BoxWrapping {}
extension Double: BoxWrapping {}

extension Array: BoxWrapping {}
extension Set: BoxWrapping {}
extension Dictionary: BoxWrapping {}
