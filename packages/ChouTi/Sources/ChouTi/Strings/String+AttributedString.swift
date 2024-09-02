//
//  String+AttributedString.swift
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

public extension String {

  /// Convert to `NSAttributedString`.
  ///
  /// - Parameters:
  ///   - attrs: The attributes to apply to the string.
  /// - Returns: A new `NSAttributedString` with the given attributes.
  @inlinable
  @inline(__always)
  func attributed(attrs: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
    NSAttributedString(string: self, attributes: attrs)
  }

  /// Convert to `NSMutableAttributedString`.
  ///
  /// - Parameters:
  ///   - attrs: The attributes to apply to the string.
  /// - Returns: A new `NSMutableAttributedString` with the given attributes.
  @inlinable
  @inline(__always)
  func mutableAttributed(attrs: [NSAttributedString.Key: Any] = [:]) -> NSMutableAttributedString {
    NSMutableAttributedString(string: self, attributes: attrs)
  }
}

/// Can use StringInterpolation to make a AttributedStrings
/// https://alisoftware.github.io/swift/2018/12/16/swift5-stringinterpolation-part2/
