//
//  String+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 7/10/24.
//  Copyright © 2024 ChouTi. All rights reserved.
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
