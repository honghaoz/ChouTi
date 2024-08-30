//
//  Locale+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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
