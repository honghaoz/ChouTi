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
  }
}
