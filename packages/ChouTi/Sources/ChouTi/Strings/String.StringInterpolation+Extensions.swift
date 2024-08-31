//
//  String.StringInterpolation+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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

public extension String.StringInterpolation {

  /// Provides convenient string interpolation for `Optional` values.
  ///
  /// This method allows you to interpolate optional values into a string,
  /// specifying a default value to use when the optional is `nil`.
  /// It eliminates the need for explicit unwrapping or using `String(describing:)`.
  ///
  /// Example:
  /// ```swift
  /// let valueOrNil: String? = nil
  /// let string = "There's \(valueOrNil, default: "nil")"
  /// ```
  ///
  /// ```swift
  /// let name: String? = nil
  /// let greeting = "Hello, \(name, default: "Guest")!"
  /// print(greeting) // Output: "Hello, Guest!"
  ///
  /// let age: Int? = 30
  /// let description = "Age: \(age, default: "unknown")"
  /// print(description) // Output: "Age: 30"
  /// ```
  ///
  /// - Parameters:
  ///   - value: The optional value to interpolate.
  ///   - defaultValue: The string to use if the optional value is `nil`.
  mutating func appendInterpolation(_ value: (some Any)?, default defaultValue: String) {
    if let value {
      appendInterpolation(value)
    } else {
      appendLiteral(defaultValue)
    }
  }
}
