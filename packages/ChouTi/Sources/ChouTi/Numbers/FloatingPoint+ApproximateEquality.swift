//
//  FloatingPoint+ApproximateEquality.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension FloatingPoint {

  /// Returns true if self and other are approximately equal.
  ///
  /// - Parameters:
  ///   - other: The value to compare with `self`.
  ///   - absoluteTolerance: The absolute tolerance value.
  /// - Returns: `true` if `self` and `other` are approximately equal; otherwise, `false`.
  func isApproximatelyEqual(to other: Self, absoluteTolerance: Self) -> Bool {
    Swift.abs(self - other) <= absoluteTolerance
  }
}

// References:
// https://github.com/apple/swift-evolution/blob/main/proposals/0259-approximately-equal.md
// https://github.com/apple/swift-numerics/blob/main/Sources/RealModule/ApproximateEquality.swift
