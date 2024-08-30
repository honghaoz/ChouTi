//
//  String+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 7/10/24.
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
