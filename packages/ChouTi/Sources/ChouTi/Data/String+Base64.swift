//
//  String+Base64.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/7/21.
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

public extension String {

  /// Convert a plain string to a base64 string.
  ///
  /// - Returns: The base64 string of the plain string.
  func base64EncodedString() -> String {
    // string -> utf 8 data -> base64 string
    Data(utf8).base64EncodedString()
  }

  /// Convert a base64 string to a plain string.
  ///
  /// - Returns: The plain string of the base64 string.
  func base64DecodedString() -> String? {
    // base64 string -> utf 8 data -> string
    guard let data = Data(base64Encoded: self) else {
      return nil
    }
    return data.utf8String()
  }
}

/// References:
/// https://stackoverflow.com/a/35360697/3164091
