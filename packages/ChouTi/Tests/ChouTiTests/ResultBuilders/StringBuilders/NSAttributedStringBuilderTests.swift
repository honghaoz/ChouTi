//
//  NSAttributedStringBuilderTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/1/24.
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

private typealias Font = NSFont
#endif

#if canImport(UIKit)
import UIKit

private typealias Font = UIFont
#endif

import ChouTiTest

import ChouTi

class NSAttributedStringBuilderTests: XCTestCase {

  func test_empty() {
    let result = NSAttributedString {}
    expect(result.string) == ""
  }

  func test_one() {
    // string
    do {
      let result = NSAttributedString {
        "Hello"
      }
      expect(result.string) == "Hello"
    }

    // attributed string
    do {
      let attributedString = NSAttributedString(string: "Hello")
      let result = NSAttributedString {
        attributedString
      }
      expect(result.string) == "Hello"
      expect(result) !== attributedString
    }

    // mutable attributed string
    do {
      let mutableAttributedString = NSMutableAttributedString(string: "Hello")
      let result = NSAttributedString {
        mutableAttributedString
      }
      expect(result.string) == "Hello"
      expect(result) !== mutableAttributedString

      // when modify the original mutable attributed string
      mutableAttributedString.append(" World".attributed())

      // the result string should not change
      expect(mutableAttributedString.string) == "Hello World"
      expect(result.string) == "Hello"
    }
  }

  func test_multiple() {
    // simple case
    do {
      let result = NSAttributedString {
        "Hello"
        "World"
      }
      expect(result.string) == "HelloWorld"
    }

    // with simple separator
    do {
      let result = NSAttributedString(separator: ", ") {
        "Hello"
        "World"
      }
      expect(result.string) == "Hello, World"
    }

    // with attributed separator
    do {
      let separator = "-".mutableAttributed(attributes: [.font: Font.systemFont(ofSize: 16)])
      let result = NSAttributedString(separator: separator) {
        "0"
        "2"
        "4"
      }
      expect(result.string) == "0-2-4"
      expect(result.attribute(.font, at: 0, effectiveRange: nil) as? Font) == nil
      expect(result.attribute(.font, at: 1, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(result.attribute(.font, at: 2, effectiveRange: nil) as? Font) == nil
      expect(result.attribute(.font, at: 3, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(result.attribute(.font, at: 4, effectiveRange: nil) as? Font) == nil

      // when modify the original mutable attributed string
      separator.addAttribute(.font, value: Font.systemFont(ofSize: 12), range: NSRange(location: 0, length: separator.length))

      // the result string should not change
      expect(result.string) == "0-2-4"
      expect(result.attribute(.font, at: 0, effectiveRange: nil) as? Font) == nil
      expect(result.attribute(.font, at: 1, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(result.attribute(.font, at: 2, effectiveRange: nil) as? Font) == nil
      expect(result.attribute(.font, at: 3, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(result.attribute(.font, at: 4, effectiveRange: nil) as? Font) == nil
    }

    // first component is mutable attributed string
    do {
      let mutableAttributedString = NSMutableAttributedString(string: "0", attributes: [.font: Font.systemFont(ofSize: 16)])
      expect(mutableAttributedString.string) == "0"
      expect(mutableAttributedString.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)

      let result = NSAttributedString(separator: "-") {
        mutableAttributedString
        "2"
      }
      expect(result.string) == "0-2"
      expect(result.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(result.attribute(.font, at: 1, effectiveRange: nil) as? Font) == nil
      expect(result.attribute(.font, at: 2, effectiveRange: nil) as? Font) == nil

      // the mutable attributed string is untouched
      expect(mutableAttributedString.string) == "0"
      expect(mutableAttributedString.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)

      // when modify the original mutable attributed string
      mutableAttributedString.append("0".attributed(attributes: [.font: Font.systemFont(ofSize: 12)]))
      expect(mutableAttributedString.string) == "00"
      expect(mutableAttributedString.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(mutableAttributedString.attribute(.font, at: 1, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 12)

      // the result string should not change
      expect(result.string) == "0-2"
      expect(result.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
      expect(result.attribute(.font, at: 1, effectiveRange: nil) as? Font) == nil
      expect(result.attribute(.font, at: 2, effectiveRange: nil) as? Font) == nil
    }
  }

  func test_attributes() {
    let attributedString1 = NSAttributedString(string: "Hello", attributes: [.font: Font.systemFont(ofSize: 12, weight: .regular)])
    let attributedString2 = NSAttributedString(string: "World", attributes: [.font: Font.systemFont(ofSize: 14, weight: .regular)])
    let result = NSAttributedString {
      attributedString1
      attributedString2
    }
    expect(result.string) == "HelloWorld"
    expect(result.attributes(at: 0, effectiveRange: nil)[.font] as? Font) == Font.systemFont(ofSize: 12, weight: .regular)
    expect(result.attributes(at: 5, effectiveRange: nil)[.font] as? Font) == Font.systemFont(ofSize: 14, weight: .regular)
  }
}
