//
//  Expectation+BeApproximatelyEqual.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is approximately equal to the expected value.
public struct BeApproximatelyEqualExpectation<T: FloatingPoint>: Expectation {

  public typealias ThrownErrorType = Never

  fileprivate let value: T
  fileprivate let tolerance: T

  public func evaluate(_ actualValue: T) -> Bool {
    Swift.abs(value - actualValue) <= tolerance
  }

  public var description: String {
    "be approximately equal to \"\(value) ± \(tolerance)\""
  }
}

/// Expect the actual value is approximately equal to the expected value.
/// - Parameters:
///   - value: The expected value.
///   - tolerance: The absolute tolerance to compare the actual value and the expected value.
/// - Returns: An expectation.
public func beApproximatelyEqual<T>(to value: T, within tolerance: T) -> BeApproximatelyEqualExpectation<T> {
  BeApproximatelyEqualExpectation(value: value, tolerance: tolerance)
}
