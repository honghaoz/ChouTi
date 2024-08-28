//
//  ObfuscationTests.swift
//
//  Created by Honghao Zhang on 1/7/24.
//  Copyright © 2024 ChouTi. All rights reserved.
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
