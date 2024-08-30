//
//  Expectation.swift
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

/// An expectation to be evaluated.
public protocol Expectation<T, ThrownErrorType> {

  associatedtype T
  associatedtype ThrownErrorType

  /// Evaluate the expectation with an actual value.
  ///
  /// - Parameter actualValue: The actual value from an expression.
  /// - Returns: Returns `true` if the expectation is met.
  func evaluate(_ actualValue: T) -> Bool

  /// Evaluate the expectation with a thrown error.
  /// - Parameter thrownError: The thrown error from an expression.
  /// - Returns: Returns `true` if the expectation is met.
  func evaluateError(_ thrownError: ThrownErrorType) -> Bool

  /// The `be equal to <expected value>` part of the sentence `expect <actual value> to 'be equal to <expected value>'`.
  ///
  /// The description is only used in actual value evaluations. Not used in thrown error evaluations.
  var description: String { get }
}

/// Default implementation.
public extension Expectation where ThrownErrorType == Never {

  func evaluateError(_ thrownError: ThrownErrorType) -> Bool {}
}
