//
//  Expectation.swift
//
//  Created by Honghao Zhang on 10/15/23.
//  Copyright © 2024 ChouTi. All rights reserved.
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
