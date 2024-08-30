//
//  OptionalBox.swift
//  ChouTi
//
//  Created by Honghao Zhang on 6/27/22.
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

/// A box express the existence of a value.
public enum OptionalBox<T>: CustomStringConvertible {

  /// Wraps a value into an `OptionalBox`.
  /// - Parameter value: The value to be wrapped.
  /// - Returns: An `OptionalBox` that wraps the value.
  public static func wrap(_ value: T?) -> Self {
    if let value {
      return .some(value)
    } else {
      return .none
    }
  }

  /// Value is not set.
  case notSet

  /// Value is set to none (aka `nil`).
  case none

  /// Value is set to some value.
  case some(T)

  /// The value if it's set to some value.
  public var value: T? {
    switch self {
    case .notSet:
      return nil
    case .none:
      return nil
    case .some(let value):
      return value
    }
  }

  /// Indicates if the value is not set yet.
  public var isNotSet: Bool {
    switch self {
    case .notSet:
      return true
    case .none,
         .some:
      return false
    }
  }

  /// Indicates if the value is an explicit `nil` or `.some`.
  @inlinable
  @inline(__always)
  public var hasValue: Bool {
    !isNotSet
  }

  /// Convert the box to an `Optional<Any>`.
  /// - Returns: An `Optional<Any>` that wraps the same value.
  public func asAny() -> OptionalBox<Any> {
    switch self {
    case .notSet:
      return .notSet
    case .none:
      return .none
    case .some(let value):
      return .some(value)
    }
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    switch self {
    case .notSet:
      return "notSet"
    case .none:
      return "none"
    case .some(let value):
      return "some(\(value))"
    }
  }
}

extension OptionalBox: Equatable where T: Equatable {}

extension OptionalBox: Hashable where T: Hashable {}

public extension Optional {

  /// Wraps `self` into an `OptionalBox`.
  func wrapIntoOptionalBox() -> OptionalBox<Wrapped> {
    .wrap(self)
  }
}
