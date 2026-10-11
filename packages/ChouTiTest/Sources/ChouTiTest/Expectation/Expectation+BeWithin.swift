//
//  Expectation+BeWithin.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/11/26.
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

/// An expectation that the actual value is within a range.
public struct BeWithinExpectation<R: RangeExpression>: Expectation {

  public typealias T = R.Bound
  public typealias ThrownErrorType = Never

  fileprivate let range: R

  public func evaluate(_ actualValue: R.Bound) -> Bool {
    range.contains(actualValue)
  }

  public var description: String {
    "be within \"\(range)\""
  }
}

/// Make an expectation that the actual value is within a closed range.
///
/// For example, `expect(progress).to(beWithin(0 ... 1))`.
///
/// - Parameter range: The expected range, including both bounds.
/// - Returns: An expectation.
public func beWithin<T>(_ range: ClosedRange<T>) -> BeWithinExpectation<ClosedRange<T>> {
  BeWithinExpectation(range: range)
}

/// Make an expectation that the actual value is within a half-open range.
///
/// For example, `expect(index).to(beWithin(0 ..< count))`.
///
/// - Parameter range: The expected range, excluding the upper bound.
/// - Returns: An expectation.
public func beWithin<T>(_ range: Range<T>) -> BeWithinExpectation<Range<T>> {
  BeWithinExpectation(range: range)
}

/// Make an expectation that the actual value is between two bounds, including the bounds.
///
/// The bounds can be in either order. For example, `expect(value).to(beBetween(later, and: earlier))`.
///
/// - Parameters:
///   - bound: One bound of the expected range.
///   - otherBound: The other bound of the expected range.
/// - Returns: An expectation.
public func beBetween<T: Comparable>(_ bound: T, and otherBound: T) -> BeWithinExpectation<ClosedRange<T>> {
  BeWithinExpectation(range: min(bound, otherBound) ... max(bound, otherBound))
}

/// Make an expectation that the actual value is between two bounds, including the bounds and a tolerance beyond them.
///
/// The bounds can be in either order. For example, `expect(value).to(beBetween(later, and: earlier, within: 1e-6))`.
///
/// - Parameters:
///   - bound: One bound of the expected range.
///   - otherBound: The other bound of the expected range.
///   - tolerance: The absolute tolerance to extend the expected range beyond both bounds.
/// - Returns: An expectation.
public func beBetween<T: FloatingPoint>(_ bound: T, and otherBound: T, within tolerance: T) -> BeWithinExpectation<ClosedRange<T>> {
  BeWithinExpectation(range: (min(bound, otherBound) - tolerance) ... (max(bound, otherBound) + tolerance))
}
