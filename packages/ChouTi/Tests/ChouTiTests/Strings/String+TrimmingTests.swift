//
//  String+TrimmingTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/6/24.
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

class String_TrimmingTests: XCTestCase {

  // MARK: - Removing Characters

  func testRemovingCharacters() {
    // basic functionality
    expect("Hello$%^& World!!123".removingCharacters(in: "$%^&!123")) == "Hello World"
    expect("Hello, World!".removingCharacters(in: ",!")) == "Hello World"

    // empty string
    expect("".removingCharacters(in: "abc")) == ""

    // no characters to remove
    expect("Hello, World!".removingCharacters(in: "")) == "Hello, World!"

    // removing all characters
    expect("Hello, World!".removingCharacters(in: "Hello, World!")) == ""

    expect("🌈👨‍👩‍👧‍👦".removingCharacters(in: "🌈")) == "👨‍👩‍👧‍👦"

    // unicode characters
    expect("Hello 🌍🌎🌏!".removingCharacters(in: "🌍🌎")) == "Hello 🌏!"

    // repeating characters
    expect("aabbccaabbcc".removingCharacters(in: "ac")) == "bbbb"

    // repeating removing characters
    expect("abcdefg".removingCharacters(in: "aaacee")) == "bdfg"

    // case sensitivity
    expect("HeLLo, WoRLd!".removingCharacters(in: "lo")) == "HeLL, WRLd!"

    // whitespace
    expect("  Hello,   World!  ".removingCharacters(in: " ")) == "Hello,World!"

    // numbers
    expect("a1b2c3d4e5".removingCharacters(in: "13579")) == "ab2cd4e"

    // special characters
    expect("a@b#c$d%e^f&g*h".removingCharacters(in: "@#$%^&*")) == "abcdefgh"

    // substring
    do {
      let string = "Hello, World!"
      expect(string[string.startIndex ... string.index(string.startIndex, offsetBy: 4)].removingCharacters(in: "e")) == "Hllo"
    }

    // performance
    // measure {
    //   let longString = String(repeating: "abcdefghijklmnopqrstuvwxyz", count: 1000)
    //   _ = longString.removingCharacters(in: "aeiou")
    // }
  }

  func testRemovingCharacters2() {
    expect("Hello World".removingCharacters(in: "$%^&!123")) == "Hello World"
    expect("Hello$%^& World!!123".removingCharacters(in: "$%^&!123")) == "Hello World"
    expect("1234567890".removingCharacters(in: "$%^&!123")) == "4567890"
    expect("".removingCharacters(in: "$%^&!123")) == ""
    expect("🙂🙃😉".removingCharacters(in: "🙃")) == "🙂😉"
    expect("🙂🙃😉🙃".removingCharacters(in: "🙃")) == "🙂😉"
    expect("éclat".removingCharacters(in: "é")) == "clat"
    expect("cléat".removingCharacters(in: "é")) == "clat"
    expect("cléaté".removingCharacters(in: "é")) == "clat"
    expect("éclat".removingCharacters(in: "e")) == "éclat"
    expect("é你écla好t".removingCharacters(in: "é")) == "你cla好t"
    expect("é你écla好t".removingCharacters(in: "e")) == "é你écla好t"
  }

  func testRemovingCharactersWithCharacterSet() {
    // empty string
    expect("".removingCharacters(in: .punctuationCharacters)) == ""

    // no matching characters
    expect("Hello World".removingCharacters(in: .decimalDigits)) == "Hello World"

    // all matching characters
    expect("12345".removingCharacters(in: .decimalDigits)) == ""

    // mixed characters
    expect("Hello, World! 123".removingCharacters(in: .punctuationCharacters)) == "Hello World 123"

    // whitespace
    expect("  Hello  World  ".removingCharacters(in: .whitespaces)) == "HelloWorld"

    // unicode characters
    expect("Héllö Wörld!".removingCharacters(in: .letters)) == " !"

    // custom CharacterSet
    let customSet = CharacterSet(charactersIn: "aeiou")
    expect("Hello World".removingCharacters(in: customSet)) == "Hll Wrld"

    // multiple character sets combined
    let combinedSet = CharacterSet.punctuationCharacters.union(.decimalDigits)
    expect("Hello, World! 123".removingCharacters(in: combinedSet)) == "Hello World "

    // emoji
    expect("Hello 👋 World 🌍!".removingCharacters(in: .symbols)) == "Hello  World !"

    // substring
    do {
      let string = "Hello 👋 World 🌍!"
      expect(string[string.startIndex ... string.index(string.startIndex, offsetBy: 9)].removingCharacters(in: .symbols)) == "Hello  Wo"
    }
  }

  // MARK: - Trimming Characters

  func test_trimmingLeadingCharacter() {
    // basic functionality
    expect("aaabacdef".trimmingLeadingCharacter("a")) == "bacdef"

    // emoji
    expect("🍎🍎🍊🍋Fruits".trimmingLeadingCharacter("🍎")) == "🍊🍋Fruits"

    // empty string
    expect("".trimmingLeadingCharacter("a")) == ""

    // no characters to trim
    expect("Hello".trimmingLeadingCharacter("a")) == "Hello"
  }

  func test_trimmingLeadingCharacters() {
    // empty string
    expect("".trimmingLeadingCharacters(in: .whitespaces)) == ""
    expect("".trimmingLeadingCharacters(in: "")) == ""

    // string with no characters to trim
    expect("Hello".trimmingLeadingCharacters(in: .whitespaces)) == "Hello"
    expect("Hello".trimmingLeadingCharacters(in: "")) == "Hello"

    // string with all characters to trim
    expect("   ".trimmingLeadingCharacters(in: .whitespaces)) == ""
    expect("   ".trimmingLeadingCharacters(in: " ")) == ""

    // string with leading characters to trim
    expect("   Hello".trimmingLeadingCharacters(in: .whitespaces)) == "Hello"
    expect("   Hello".trimmingLeadingCharacters(in: " ")) == "Hello"

    // string with leading and trailing characters to trim
    expect("   Hello   ".trimmingLeadingCharacters(in: .whitespaces)) == "Hello   "
    expect("   Hello   ".trimmingLeadingCharacters(in: " ")) == "Hello   "

    // custom character set
    let customSet = CharacterSet(charactersIn: "123")
    expect("123abc123".trimmingLeadingCharacters(in: customSet)) == "abc123"
    expect("123abc123".trimmingLeadingCharacters(in: "123")) == "abc123"

    expect("aaabacdef".trimmingLeadingCharacters(in: CharacterSet(charactersIn: "ab"))) == "cdef"
    expect("aaabacdef".trimmingLeadingCharacters(in: "ab")) == "cdef"

    // empty character set
    expect("Hello".trimmingLeadingCharacters(in: CharacterSet())) == "Hello"
    expect("Hello".trimmingLeadingCharacters(in: "")) == "Hello"

    // unicode characters
    expect("🍎🍊🍋Fruits".trimmingLeadingCharacters(in: CharacterSet(charactersIn: "🍎🍊"))) == "🍋Fruits"
    expect("🍎🍊🍋Fruits".trimmingLeadingCharacters(in: "🍎🍊")) == "🍋Fruits"

    // substring
    let substring = "   Hello World   ".dropLast(3)
    expect(substring.trimmingLeadingCharacters(in: .whitespaces)) == "Hello World"
    expect(substring.trimmingLeadingCharacters(in: " ")) == "Hello World"

    // very long string
    let longString = String(repeating: " ", count: 10000) + "Hello"
    expect(longString.trimmingLeadingCharacters(in: .whitespaces)) == "Hello"
    expect(longString.trimmingLeadingCharacters(in: " ")) == "Hello"
  }

  func test_trimmingTrailingCharacter() {
    // basic functionality
    expect("abcdefaaa".trimmingTrailingCharacter("a")) == "abcdef"

    // emoji
    expect("Fruits🍋🍊🍎🍎".trimmingTrailingCharacter("🍎")) == "Fruits🍋🍊"

    // empty string
    expect("".trimmingTrailingCharacter("a")) == ""

    // no characters to trim
    expect("Hello".trimmingTrailingCharacter("a")) == "Hello"
  }

  func test_trimmingTrailingCharacters() {
    // empty string
    expect("".trimmingTrailingCharacters(in: .whitespaces)) == ""
    expect("".trimmingTrailingCharacters(in: "")) == ""

    // string with no characters to trim
    expect("Hello".trimmingTrailingCharacters(in: .whitespaces)) == "Hello"
    expect("Hello".trimmingTrailingCharacters(in: "")) == "Hello"

    // string with all characters to trim
    expect("   ".trimmingTrailingCharacters(in: .whitespaces)) == ""
    expect("   ".trimmingTrailingCharacters(in: " ")) == ""

    // string with trailing characters to trim
    expect("Hello   ".trimmingTrailingCharacters(in: .whitespaces)) == "Hello"
    expect("Hello   ".trimmingTrailingCharacters(in: " ")) == "Hello"

    // string with leading and trailing characters to trim
    expect("   Hello   ".trimmingTrailingCharacters(in: .whitespaces)) == "   Hello"
    expect("   Hello   ".trimmingTrailingCharacters(in: " ")) == "   Hello"

    // custom character set
    let customSet = CharacterSet(charactersIn: "123")
    expect("123abc123".trimmingTrailingCharacters(in: customSet)) == "123abc"
    expect("123abc123".trimmingTrailingCharacters(in: "123")) == "123abc"

    expect("abcdefaaa".trimmingTrailingCharacters(in: CharacterSet(charactersIn: "ab"))) == "abcdef"
    expect("abcdefaaa".trimmingTrailingCharacters(in: "ab")) == "abcdef"

    // empty character set
    expect("Hello".trimmingTrailingCharacters(in: CharacterSet())) == "Hello"
    expect("Hello".trimmingTrailingCharacters(in: "")) == "Hello"

    // unicode characters
    expect("Fruits🍋🍊🍎".trimmingTrailingCharacters(in: CharacterSet(charactersIn: "🍎🍊"))) == "Fruits🍋"
    expect("Fruits🍋🍊🍎".trimmingTrailingCharacters(in: "🍎🍊")) == "Fruits🍋"

    // substring
    let substring = "   Hello World   ".dropFirst(3)
    expect(substring.trimmingTrailingCharacters(in: .whitespaces)) == "Hello World"
    expect(substring.trimmingTrailingCharacters(in: " ")) == "Hello World"

    // very long string
    let longString = "Hello" + String(repeating: " ", count: 10000)
    expect(longString.trimmingTrailingCharacters(in: .whitespaces)) == "Hello"
    expect(longString.trimmingTrailingCharacters(in: " ")) == "Hello"
  }

  func testLeadingTrimmed() {
    expect("aaabcdef".trimmingLeadingCharacter("a")) == "bcdef"
    expect("  aaabcdef".trimmingLeadingCharacter(" ")) == "aaabcdef"
    expect("  aaabcdef   ".trimmingLeadingCharacter(" ")) == "aaabcdef   "

    expect("aaaThink different.".trimmingLeadingCharacters(in: "a")) == "Think different."
    expect("aaaThink different.".trimmingLeadingCharacters(in: "aa")) == "Think different."
    expect("000.20".trimmingLeadingCharacters(in: "0.")) == "20"
    expect("+012.20".trimmingLeadingCharacters(in: "0+")) == "12.20"
    expect("+0012.23".trimmingLeadingCharacters(in: "0+")) == "12.23"
  }

  func testTrailingTrimmed() {
    expect("Think different.\n\n".trimmingTrailingCharacter("\n")) == "Think different."
    expect("aaabcdef".trimmingTrailingCharacter("f")) == "aaabcde"
    expect("  aaabcdef  ".trimmingTrailingCharacter(" ")) == "  aaabcdef"
    expect("  aaabcdeff".trimmingTrailingCharacter("f")) == "  aaabcde"
    expect("  aaabcdeff\n".trimmingTrailingCharacter("\n")) == "  aaabcdeff"

    expect("120.00".trimmingTrailingCharacter("0").trimmingTrailingCharacter(".")) == "120"

    expect("Think different.\n \n ".trimmingTrailingCharacters(in: " \n")) == "Think different."
    expect("Think different.\n \n ".trimmingTrailingCharacters(in: "   \n ")) == "Think different."
    expect("120.00".trimmingTrailingCharacters(in: "0.")) == "12"
    expect("12.20".trimmingTrailingCharacters(in: "0.")) == "12.2"
    expect("12.23".trimmingTrailingCharacters(in: "0.")) == "12.23"
  }
}
