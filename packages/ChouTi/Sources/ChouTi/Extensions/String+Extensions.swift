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
      // Force unwrap is safe here because:
      // 1. We've verified the input is two ASCII letters (A-Z)
      // 2. ASCII values for A-Z (65-90) when added to the base (127397)
      //    always result in valid Unicode scalars (127462-127487)
      let scalar = UnicodeScalar(base + v.value)! // swiftlint:disable:this force_unwrapping
      s.unicodeScalars.append(scalar)
    }

    return String(s)
  }
}
