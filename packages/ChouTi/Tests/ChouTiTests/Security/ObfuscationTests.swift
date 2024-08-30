//
//  ObfuscationTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/7/24.
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

import ChouTi
import ChouTiTest

class ObfuscationTests: XCTestCase {

  func testObfuscation() {
    let originalString = "HelloWorld"
    let key = 5
    let obfuscatedString = Obfuscation.obfuscate(originalString, key: key)
    expect(originalString) != obfuscatedString
  }

  func testDeobfuscation() {
    let originalString = "HelloWorld"
    let key = 5
    let obfuscatedString = Obfuscation.obfuscate(originalString, key: key)
    let deobfuscatedString = Obfuscation.deobfuscate(obfuscatedString, key: key)
    expect(originalString) == deobfuscatedString
  }

  func testEmptyStringObfuscation() {
    let originalString = ""
    let key = 5
    let obfuscatedString = Obfuscation.obfuscate(originalString, key: key)
    expect(originalString) == obfuscatedString
  }

  func testZeroKeyObfuscation() {
    let originalString = "HelloWorld"
    let key = 0
    let obfuscatedString = Obfuscation.obfuscate(originalString, key: key)
    expect(originalString) == obfuscatedString
  }

  func testNegativeKeyObfuscation() {
    let originalString = "HelloWorld"
    let key = -3
    let obfuscatedString = Obfuscation.obfuscate(originalString, key: key)
    let deobfuscatedString = Obfuscation.deobfuscate(obfuscatedString, key: key)
    expect(originalString) == deobfuscatedString
  }

  func testObfuscateWithLargeUnicodeScalar() {
    let largeUnicodeScalar = "\u{10FFFF}" // Largest valid Unicode scalar
    let result = Obfuscation.obfuscate(largeUnicodeScalar, key: 1)
    expect(result, "Should return original character when shift results in invalid Unicode scalar") == largeUnicodeScalar
  }

  func testDeobfuscateWithSmallUnicodeScalar() {
    let smallUnicodeScalar = "\u{0000}" // Smallest valid Unicode scalar
    let result = Obfuscation.deobfuscate(smallUnicodeScalar, key: 1)
    expect(result, "Should return original character when shift results in invalid Unicode scalar") == smallUnicodeScalar
  }
}
