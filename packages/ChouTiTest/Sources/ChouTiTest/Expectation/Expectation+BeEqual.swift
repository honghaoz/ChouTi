//
//  Expectation+BeEqual.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/15/23.
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

/// An expectation that the actual value is equal to the expected value.
public struct BeEqualExpectation<T: Equatable>: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T

  public func evaluate(_ actualValue: T) -> Bool {
    actualValue == value
  }

  public var description: String {
    if let optionalValue = value as? OptionalProtocol {
      return "be equal to \"\(optionalValue.wrappedValueDescription)\""
    } else {
      return "be equal to \"\(value)\""
    }
  }
}

/// Make an expectation that the actual value is equal to the expected value.
/// - Parameter value: The expected value.
/// - Returns: An expectation.
public func beEqual<T>(to value: T) -> BeEqualExpectation<T> {
  BeEqualExpectation(value: value)
}

public extension Expression {

  static func == (lhs: Self, rhs: T) where T: Equatable {
    lhs.to(BeEqualExpectation(value: rhs))
  }

  static func != (lhs: Self, rhs: T) where T: Equatable {
    lhs.toNot(BeEqualExpectation(value: rhs))
  }
}
