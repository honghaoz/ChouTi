//
//  String+Extensions.swift
//
//  Created by Honghao Zhang on 7/10/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension String {

  /// Get flag emoji from country code.
  var countryFlagEmoji: String {
    let countryCode = self.uppercased()
    let base: UInt32 = 127397
    var s = ""
    for v in countryCode.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
}
