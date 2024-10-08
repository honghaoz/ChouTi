//
//  NSAttributedString+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/9/22.
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

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public extension NSAttributedString {

  // MARK: - Range

  /// The full range of the attributed string.
  @inlinable
  @inline(__always)
  var fullRange: NSRange {
    NSRange(location: 0, length: length)
  }

  // MARK: - Copy

  /// Make a new copy.
  /// - Returns: A new copy.
  func makeCopy() -> Self {
    Self(attributedString: self)
  }

  /// Return a mutable `NSMutableAttributedString`.
  ///
  /// If `self` is already a `NSMutableAttributedString` and if `copy == false`, returns `self` directly.
  ///
  /// - Parameter copy: If should always make a new copy.
  /// - Returns: A mutable version of attributed string.
  @inlinable
  @inline(__always)
  func mutable(copy: Bool) -> NSMutableAttributedString {
    if let mutable = self as? NSMutableAttributedString {
      if copy {
        return NSMutableAttributedString(attributedString: self)
      } else {
        return mutable
      }
    } else {
      return NSMutableAttributedString(attributedString: self)
    }
  }

  // MARK: - Attributes

  /// Checks if the string contains links.
  @inlinable
  @inline(__always)
  func containsLink() -> Bool {
    contains(.link)
  }

  /// Checks if the string contains font attribute.
  @inlinable
  @inline(__always)
  func containsFont() -> Bool {
    contains(.font)
  }

  /// Checks if the string contains foreground color attribute.
  @inlinable
  @inline(__always)
  func containsForegroundColor() -> Bool {
    contains(.foregroundColor)
  }

  /// Check if attributed string contains a specific attribute.
  ///
  /// - Parameter attribute: The attribute to check.
  /// - Returns: `true` if the attributed string contains the attribute, `false` otherwise.
  func contains(_ attribute: NSAttributedString.Key) -> Bool {
    var has = false
    enumerateAttribute(attribute, in: fullRange) { value, range, stop in
      if value != nil {
        has = true
        // how to stop
        // https://stackoverflow.com/a/41547265/3164091
        stop.pointee = true
      }
    }
    return has
  }
}

// MARK: - Addition

public extension NSAttributedString {

  /// Concatenate two `NSAttributedString`s.
  static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSMutableAttributedString {
    let mutable = lhs.mutable(copy: true)
    mutable.append(rhs)
    return mutable
  }
}

/**
 Opening hyperlinks in UILabel on iOS:
 https://augmentedcode.io/2020/12/20/opening-hyperlinks-in-uilabel-on-ios/
 Embedding Hyperlinks in NSTextField and NSTextView:
 https://developer.apple.com/library/archive/qa/qa1487/_index.html
 */
