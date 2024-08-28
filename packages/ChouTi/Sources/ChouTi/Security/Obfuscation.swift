//
//  Obfuscation.swift
//
//  Created by Honghao Zhang on 1/7/24.
//  Copyright © 2024 ChouTi. All rights reserved.
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
