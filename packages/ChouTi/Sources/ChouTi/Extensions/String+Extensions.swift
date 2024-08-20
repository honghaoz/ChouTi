//
//  String+Extensions.swift
//
//  Created by Honghao Zhang on 7/10/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension String {

  /// Get flag emoji from country code.
  ///
  /// Invalid input returns 🏴‍☠️ as a fallback.
  var countryFlagEmoji: String {
    let unknownFlag = "🏴‍☠️"

    let countryCode = self.uppercased()
    guard countryCode.count == 2,
          countryCode.allSatisfy({ $0.isASCII && $0.isLetter })
    else {
      return unknownFlag
    }

    let base: UInt32 = 127397
    var s = ""
    for v in countryCode.unicodeScalars {
      guard let scalar = UnicodeScalar(base + v.value) else {
        return unknownFlag
      }
      s.unicodeScalars.append(scalar)
    }

    return String(s)
  }
}
