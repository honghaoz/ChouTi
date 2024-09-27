//
//  Data+Decoding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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

// MARK: - Data to String

public extension Data {

  /// Convert the data to a string with the specified encoding.
  ///
  /// - Parameter encoding: The encoding type.
  /// - Returns: A string representation of the Data, or nil if the conversion fails.
  @inlinable
  @inline(__always)
  func string(encoding: String.Encoding) -> String? {
    String(data: self, encoding: encoding)
  }

  /// Convert the data to a string with UTF-8 encoding.
  ///
  /// - Warning: ⚠️ This method could return malformed string if the data is not a valid UTF-8 sequence.
  /// Please use `string(encoding: .utf8)` instead.
  /// See more details at https://github.com/realm/SwiftLint/issues/5263#issuecomment-2115182747
  ///
  /// - Returns: A UTF-8 string representation of the Data.
  @inlinable
  @inline(__always)
  func utf8String() -> String {
    String(decoding: self, as: UTF8.self) // swiftlint:disable:this optional_data_string_conversion
  }
}
