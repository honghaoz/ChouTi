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
    let unknwonFlag = "🏴‍☠️"

    let countryCode = self.uppercased()
    guard countryCode.count == 2 else {
      return unknwonFlag
    }

    let base: UInt32 = 127397
    var s = ""
    for v in countryCode.unicodeScalars {
      if let scalar = UnicodeScalar(base + v.value) {
        s.unicodeScalars.append(scalar)
      } else {
        return unknwonFlag
      }
    }

    return String(s)
  }
}
