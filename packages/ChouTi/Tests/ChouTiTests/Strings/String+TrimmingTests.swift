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

    // performance
    // measure {
    //   let longString = String(repeating: "abcdefghijklmnopqrstuvwxyz", count: 1000)
    //   _ = longString.removingCharacters(in: "aeiou")
    // }
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
  }
}
