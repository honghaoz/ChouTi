//
//  Describe.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/10/26.
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

/// Returns the description of a value for failure messages.
///
/// The same as `String(describing:)`, except that types use their fully qualified names, e.g. `MyModule.Outer.Inner`
/// instead of `Inner`, so that types with the same name are distinguishable.
///
/// - Parameter value: The value to describe.
/// - Returns: The description of the value.
func describe(_ value: Any) -> String {
  guard let type = value as? Any.Type else {
    return String(describing: value)
  }

  return String(reflecting: type).replacingOccurrences(of: Constants.anonymousContextPattern, with: "", options: .regularExpression)
}

// MARK: - Constants

private enum Constants {

  /// The pattern of the anonymous contexts in the fully qualified names of private and local types.
  ///
  /// For example, `(unknown context at $10a3c8f2c).` in `MyModule.(unknown context at $10a3c8f2c).Foo`.
  /// The address is not stable across builds and the context is not readable, so it's removed.
  static let anonymousContextPattern = #"\(unknown context at [^)]+\)\."#
}
