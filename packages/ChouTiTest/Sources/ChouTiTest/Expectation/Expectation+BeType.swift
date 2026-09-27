//
//  Expectation+BeType.swift
//  ChouTi
//
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

/// An expectation that the actual metatype is exactly the expected type.
///
/// A subclass is distinct from its superclass. Type aliases are equal to the type they name.
public struct BeTypeExpectation: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: Any.Type

  public func evaluate(_ actualValue: Any.Type) -> Bool {
    ObjectIdentifier(actualValue) == ObjectIdentifier(value)
  }

  public var description: String {
    "be type \"\(value)\""
  }
}

/// Make an expectation that a metatype is exactly the expected type.
///
/// For example, `expect(Int.self).to(beType(Int.self))`.
/// Optional metatypes can use the same matcher; `nil` fails `to` and passes `toNot`.
/// - Parameter value: The expected metatype.
/// - Returns: An expectation that compares exact type identity.
public func beType(_ value: Any.Type) -> BeTypeExpectation {
  BeTypeExpectation(value: value)
}

public extension Expression where T == Any.Type {

  /// Assert that the actual metatype is exactly the expected type.
  static func == (lhs: Self, rhs: Any.Type) {
    lhs.to(beType(rhs))
  }

  /// Assert that the actual metatype differs from the expected type.
  static func != (lhs: Self, rhs: Any.Type) {
    lhs.toNot(beType(rhs))
  }
}

public extension OptionalExpression where T == Any.Type {

  /// Assert that the metatypes are equal, or both are `nil`.
  static func == (lhs: Self, rhs: Any.Type?) {
    if let rhs {
      lhs.to(beType(rhs))
    } else {
      lhs.to(beNil())
    }
  }

  /// Assert that the metatypes differ, including when only one is `nil`.
  static func != (lhs: Self, rhs: Any.Type?) {
    if let rhs {
      lhs.toNot(beType(rhs))
    } else {
      lhs.toNot(beNil())
    }
  }
}
