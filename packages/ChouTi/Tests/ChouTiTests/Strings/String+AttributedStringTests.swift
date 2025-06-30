//
//  String+AttributedStringTests.swift
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

class String_AttributedStringTests: XCTestCase {

  func test_attributed() {
    let str = "Hello, World!"
    let attr = str.attributed()
    expect(attr.string) == str

    let attr2 = str.attributed(attributes: [.font: Font.systemFont(ofSize: 16)])
    expect(attr2.string) == str
    expect(attr2.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
  }

  func test_mutableAttributed() {
    let str = "Hello, World!"
    let attr = str.mutableAttributed()
    expect(attr.string) == str

    attr.addAttribute(.font, value: Font.systemFont(ofSize: 16), range: NSRange(location: 0, length: str.count))
    expect(attr.string) == str
    expect(attr.attribute(.font, at: 0, effectiveRange: nil) as? Font) == Font.systemFont(ofSize: 16)
  }
}
