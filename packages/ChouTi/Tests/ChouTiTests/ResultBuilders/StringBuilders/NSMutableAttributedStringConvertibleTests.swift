//
//  NSMutableAttributedStringConvertibleTests.swift
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

import ChouTiTest
import ChouTi

class NSMutableAttributedStringConvertibleTests: XCTestCase {

  func test_attributedString_asMutableAttributedString() {
    let attributedString = NSAttributedString(string: "Hello, World!")
    let mutableAttributedString: NSMutableAttributedString = attributedString.asMutableAttributedString()
    expect(mutableAttributedString.string) == "Hello, World!"
    expect(mutableAttributedString) !== attributedString
  }

  func test_mutableAttributedString_asMutableAttributedString() {
    let mutableAttributedString = NSMutableAttributedString(string: "Hello, World!")
    let mutableAttributedString2: NSMutableAttributedString = mutableAttributedString.asMutableAttributedString()
    expect(mutableAttributedString2.string) == "Hello, World!"
    expect(mutableAttributedString2) === mutableAttributedString
  }

  func test_string_asMutableAttributedString() {
    let string = "Hello, World!"
    let mutableAttributedString: NSMutableAttributedString = string.asMutableAttributedString()
    expect(mutableAttributedString.string) == "Hello, World!"
  }
}
