//
//  Obfuscation.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/7/24.
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

public enum Obfuscation {

  /// Obfuscates a string using basic character shift algorithm.
  ///
  /// - Parameters:
  ///   - string: The string that needs to be obfuscated.
  ///   - key: The shift key for the obfuscation.
  /// - Returns: An obfuscated version of the input string.
  public static func obfuscate(_ string: String, key: Int) -> String {
    guard key >= 0 else {
      return string
    }

    return String(string.unicodeScalars.map {
      if let scalar = UnicodeScalar($0.value + UInt32(key)) {
        return Character(scalar)
      }
      return Character($0)
    })
  }

  /// Deobfuscates a string using basic character shift algorithm.
  /// - Parameters:
  ///   - string: The string that needs to be deobfuscated.
  ///   - key: The shift key for the deobfuscation.
  /// - Returns: A deobfuscated version of the input string.
  public static func deobfuscate(_ string: String, key: Int) -> String {
    guard key >= 0 else {
      return string
    }

    return String(string.unicodeScalars.map {
      if $0.value >= UInt32(key), let scalar = UnicodeScalar($0.value - UInt32(key)) {
        return Character(scalar)
      }
      return Character($0)
    })
  }
}

/**

 #if DEBUG
 DispatchQueue.once {
   printObfuscationTable()
 }
 #endif

 // durationForEpsilon:
 let selectorString = Obfuscation.deobfuscate("l}zi|qwvNwzMx{qtwvB", key: obfuscationKey)

 private let obfuscationKey: Int = 8

 #if DEBUG

 /// durationForEpsilon:: l}zi|qwvNwzMx{qtwvB
 /// _solveForInput:: g{wt~mNwzQvx}|B
 private func printObfuscationTable() {
   let strings = [
     "MKAttributionLabel",
     "MKAppleLogoLabel",
   ]

   let obfuscatedStrings = strings.map {
     Obfuscation.obfuscate($0, key: obfuscationKey)
   }

   print("🔑 \(#fileID) \(#function) 🔑 ==== BEGIN")
   for (string, obfuscatedString) in zip(strings, obfuscatedStrings) {
     print("\(string): \(obfuscatedString)")
   }
   print("🔑 \(#fileID) \(#function) 🔑 ==== END")
 }
 #endif

 */
