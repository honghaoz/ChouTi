//
//  Expectation+BeType.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/26/26.
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

/// An expectation that the actual type is exactly the expected type.
///
/// A type alias matches the type it refers to. A subclass doesn't match its superclass.
public struct BeTypeExpectation: Expectation {

  public typealias T = Any.Type
  public typealias ThrownErrorType = Never

  fileprivate let type: Any.Type

  public func evaluate(_ actualValue: Any.Type) -> Bool {
    actualValue == type
  }

  public var description: String {
    "be type \"\(describe(type))\""
  }
}

/// Make an expectation that the actual type is exactly the expected type.
///
/// Example:
/// ```swift
/// expect(type(of: view)).to(beType(MyView.self))
/// expect(object_getClass(layer)).to(beType(CALayer.self))
/// ```
///
/// - Parameter type: The expected type.
/// - Returns: An expectation.
public func beType(_ type: Any.Type) -> BeTypeExpectation {
  BeTypeExpectation(type: type)
}

public extension Expression where T == Any.Type {

  /// Expect the type to be exactly the expected type.
  static func == (lhs: Self, rhs: Any.Type) {
    lhs.to(beType(rhs))
  }

  /// Expect the type to not be exactly the expected type.
  static func != (lhs: Self, rhs: Any.Type) {
    lhs.toNot(beType(rhs))
  }
}

// `rhs` is non-optional so that `== nil` and `!= nil` only match the `BeNilExpectation` overloads.
public extension OptionalExpression where T == Any.Type {

  /// Expect the type to be exactly the expected type. A `nil` type fails the expectation.
  static func == (lhs: Self, rhs: Any.Type) {
    lhs.to(beType(rhs))
  }

  /// Expect the type to not be exactly the expected type. A `nil` type passes the expectation.
  static func != (lhs: Self, rhs: Any.Type) {
    lhs.toNot(beType(rhs))
  }
}
