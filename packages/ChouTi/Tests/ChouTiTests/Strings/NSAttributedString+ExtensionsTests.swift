//
//  NSAttributedString+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 12/27/23.
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

import ChouTiTest

import ChouTi

class NSAttributedString_ExtensionsTests: XCTestCase {

  // MARK: - Range

  func test_fullRangeOnEmptyString() {
    let emptyAttributedString = NSAttributedString(string: "")
    let range = emptyAttributedString.fullRange
    expect(range) == NSRange(location: 0, length: 0)
  }

  func test_fullRangeOnNonEmptyString() {
    let nonEmptyString = NSAttributedString(string: "Hello World")
    let range = nonEmptyString.fullRange
    expect(range) == NSRange(location: 0, length: nonEmptyString.length)
  }

  func test_fullRangeOnStringWithAttributes() {
    #if os(macOS)
    let attributedString = NSAttributedString(string: "Test", attributes: [.font: NSFont.systemFont(ofSize: 12)])
    #else
    let attributedString = NSAttributedString(string: "Test", attributes: [.font: UIFont.systemFont(ofSize: 12)])
    #endif

    let range = attributedString.fullRange
    expect(range) == NSRange(location: 0, length: attributedString.length)
  }

  // MARK: - Copy

  func test_makeCopy() {
    let nonEmptyAttributedString = NSAttributedString(string: "Hello World")
    let copy = nonEmptyAttributedString.makeCopy()
    expect(nonEmptyAttributedString) !== copy
    expect(nonEmptyAttributedString) == copy
  }

  func test_mutableCopy_attributedString() {
    let attributedString = NSAttributedString(string: "Test")

    let mutableAlwaysCopy = attributedString.mutable(alwaysCopy: true)
    expect(attributedString) !== mutableAlwaysCopy
    expect(attributedString) == mutableAlwaysCopy

    let mutableNotAlwaysCopy = attributedString.mutable(alwaysCopy: false)
    expect(attributedString) !== mutableNotAlwaysCopy
    expect(attributedString) == mutableNotAlwaysCopy
  }

  func test_mutableCopy_mutableAttributedString() {
    let mutableAttributedString = NSMutableAttributedString(string: "Test")

    let mutableAlwaysCopy = mutableAttributedString.mutable(alwaysCopy: true)
    expect(mutableAttributedString) !== mutableAlwaysCopy
    expect(mutableAttributedString) == mutableAlwaysCopy

    let mutableNotAlwaysCopy = mutableAttributedString.mutable(alwaysCopy: false)
    expect(mutableAttributedString) === mutableNotAlwaysCopy
    expect(mutableAttributedString) == mutableNotAlwaysCopy
  }

  // MARK: - Attributes

  func test_containsLink() {
    let attributedString = NSAttributedString(string: "Test")
    expect(attributedString.contains(.link)) == false

    let linkString = NSAttributedString(string: "Test", attributes: [.link: "https://www.google.com"])
    expect(linkString.contains(.link)) == true
  }

  func test_containsFont() {
    let attributedString = NSAttributedString(string: "Test")
    expect(attributedString.contains(.font)) == false

    #if os(macOS)
    let fontString = NSAttributedString(string: "Test", attributes: [.font: NSFont.systemFont(ofSize: 12)])
    #else
    let fontString = NSAttributedString(string: "Test", attributes: [.font: UIFont.systemFont(ofSize: 12)])
    #endif
    expect(fontString.contains(.font)) == true
  }

  func test_containsForegroundColor() {
    let attributedString = NSAttributedString(string: "Test")
    expect(attributedString.contains(.foregroundColor)) == false

    #if os(macOS)
    let fontString = NSAttributedString(string: "Test", attributes: [.foregroundColor: NSColor.red])
    #else
    let fontString = NSAttributedString(string: "Test", attributes: [.foregroundColor: UIColor.red])
    #endif
    expect(fontString.contains(.foregroundColor)) == true
  }

  // MARK: - Addition

  func test_addition() {
    let attributedString1 = NSAttributedString(string: "Hello")
    let attributedString2 = NSAttributedString(string: "World")
    let combined = attributedString1 + attributedString2
    expect(attributedString1.string) == "Hello"
    expect(attributedString2.string) == "World"
    expect(combined.string) == "HelloWorld"
    expect(combined) !== attributedString1
    expect(combined) !== attributedString2
  }

  func test_addition_mutableAttributedString() {
    let mutableAttributedString1 = NSMutableAttributedString(string: "Hello")
    let attributedString2 = NSAttributedString(string: "World")
    let combined = mutableAttributedString1 + attributedString2
    expect(mutableAttributedString1.string) == "Hello"
    expect(attributedString2.string) == "World"
    expect(combined.string) == "HelloWorld"
    expect(combined) !== mutableAttributedString1
    expect(combined) !== attributedString2
  }
}
