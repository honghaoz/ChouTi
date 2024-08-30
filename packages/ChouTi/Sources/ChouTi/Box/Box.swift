//
//  Box.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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
