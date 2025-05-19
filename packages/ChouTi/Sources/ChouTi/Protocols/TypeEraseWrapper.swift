//
//  TypeEraseWrapper.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/5/24.
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

/// A type-erased wrapper type.
///
/// Example:
/// ```
/// struct AnyShape: Shape, TypeEraseWrapper {
///
///   public let wrapped: any Shape
/// }
/// ```
public protocol TypeEraseWrapper {

  associatedtype T

  /// The wrapped value.
  var wrapped: T { get }
}

/// The base type for the `wrapped` in `TypeEraseWrapper`.
///
/// Example:
/// ```
/// protocol Shape: TypeEraseWrapperBaseType {}
///
/// let someShape: any Shape = AnyShape(Rectangle())
///
/// if let rectangle = someShape as? Rectangle {
///   // cast will fail, won't execute...
/// }
///
/// if let rectangle = someShape.as(Rectangle.self) {
///   // use rectangle...
/// }
/// ```
public protocol TypeEraseWrapperBaseType {

  /// Attempt to cast `self` to the specified type.
  ///
  /// For an `any Shape`, the code `shape as? Rectangle` may fail if the `shape` is `AnyShape`, even when `AnyShape`
  /// wraps a `Rectangle` value.
  ///
  /// Use this method to correctly cast self to the specified type.
  ///
  /// Example:
  /// ```
  /// let offsetableShape = shape.as((any OffsetableShape).self)
  /// let rectangle = shape.as(Rectangle.self)
  /// ```
  ///
  /// - Parameter type: The type to cast `self` to.
  /// - Returns: The specified type if `self` can be cast, otherwise `nil`.
  func `as`<T>(_ type: T.Type) -> T?

  // swiftformat:disable opaqueGenericParameters

  /// Returns a Boolean value indicating whether the type of `self` is the same as the type of the specified type.
  ///
  /// Example:
  /// ```
  /// if shape.is(Rectangle.self) {
  ///  // shape is a Rectangle
  /// }
  /// ```
  ///
  /// - Parameter type: The type to compare to the type of `self`.
  /// - Returns: `true` if the type of `self` is the same as the type of the `type` parameter; otherwise, `false`.
  func `is`<T>(_ type: T.Type) -> Bool

  // swiftformat:enable opaqueGenericParameters
}

public extension TypeEraseWrapperBaseType {

  func `as`<T>(_ type: T.Type) -> T? {
    if let selfAsT = self as? T {
      return selfAsT
    } else if let anyShape = self as? (any TypeEraseWrapper),
              let casted = anyShape.wrapped as? T
    {
      return casted
    }
    return nil
  }

  func `is`(_ type: (some Any).Type) -> Bool {
    self.as(type) != nil
  }
}
