//
//  String+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 7/10/24.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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
import ChouTiTest

class String_ExtensionsTests: XCTestCase {

  func testCountryFlagEmoji() {
    expect("US".countryFlagEmoji) == "🇺🇸"
    expect("us".countryFlagEmoji) == "🇺🇸"
    expect("GB".countryFlagEmoji) == "🇬🇧"
    expect("CN".countryFlagEmoji) == "🇨🇳"
    expect("cn".countryFlagEmoji) == "🇨🇳"
    expect("Cn".countryFlagEmoji) == "🇨🇳"
    expect("JP".countryFlagEmoji) == "🇯🇵"
    expect("KR".countryFlagEmoji) == "🇰🇷"
    expect("TW".countryFlagEmoji) == "🇹🇼"
    expect("HK".countryFlagEmoji) == "🇭🇰"
    expect("MO".countryFlagEmoji) == "🇲🇴"
    expect("SG".countryFlagEmoji) == "🇸🇬"
    expect("MY".countryFlagEmoji) == "🇲🇾"
    expect("DE".countryFlagEmoji) == "🇩🇪"

    // bad inputs
    expect("".countryFlagEmoji) == "🏴‍☠️"
    expect("U".countryFlagEmoji) == "🏴‍☠️"
    expect("US1".countryFlagEmoji) == "🏴‍☠️"
    expect("A\u{10FFFF}".countryFlagEmoji) == "🏴‍☠️"

    // acceptable invalid inputs
    expect("ZZ".countryFlagEmoji) == "🇿🇿"

    // Non-ASCII characters
    expect("🇺🇸".countryFlagEmoji) == "🏴‍☠️"
    expect("中国".countryFlagEmoji) == "🏴‍☠️"
    expect("日本".countryFlagEmoji) == "🏴‍☠️"

    // Special characters
    expect("@#".countryFlagEmoji) == "🏴‍☠️"
    expect("12".countryFlagEmoji) == "🏴‍☠️"

    // Mixed characters
    expect("US🇺🇸".countryFlagEmoji) == "🏴‍☠️"
    expect("CN中国".countryFlagEmoji) == "🏴‍☠️"
  }
}
