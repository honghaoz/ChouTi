//
//  Locale+Extensions.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension Locale {

  static let zh = Locale(identifier: "zh")

  static let zhTraditional = Locale(identifier: "zh_Hant")
  static let zhTraditionalTW = Locale(identifier: "zh_Hant_TW")
  static let zhTraditionalHK = Locale(identifier: "zh_Hant_HK")
  static let zhTraditionalMacau = Locale(identifier: "zh_Hant_MO")

  static let zhSimplified = Locale(identifier: "zh_Hans")
  static let zhSimplifiedCN = Locale(identifier: "zh_Hans_CN")
  static let zhSimplifiedHK = Locale(identifier: "zh_Hans_HK")
  static let zhSimplifiedMacau = Locale(identifier: "zh_Hans_MO")
  static let zhSimplifiedSG = Locale(identifier: "zh_Hans_SG")

  static let enUS = Locale(identifier: "en_US")
  static let enUSPOSIX = Locale(identifier: "en_US_POSIX")
  static let enGB = Locale(identifier: "en_GB")
}

/// Reference:
/// https://gist.github.com/jacobbubu/1836273
