//
//  OptionalStringCoalescingOperator.swift
//
//  Created by Honghao Zhang on 2/18/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

infix operator ???: NilCoalescingPrecedence

/// Optional string coalescing operator.
///
/// An operator that supports string interpolation for optional values, without using `String(describing:)`.
///
/// Examples:
/// - `"\(anyOptionalValue ??? "nil")"`
/// - `String(anyOptionalValue ??? "nil")`
///
/// Reference: https://oleb.net/blog/2016/12/optionals-string-interpolation/
func ??? (lhs: (some Any)?, defaultValue: @autoclosure () -> String) -> String {
  switch lhs {
  case let value?:
    return String(describing: value)
  case nil:
    return defaultValue()
  }
}
