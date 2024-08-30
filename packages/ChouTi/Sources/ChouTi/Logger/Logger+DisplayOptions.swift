//
//  Logger+DisplayOptions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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

public extension Logger {

  struct DisplayOptions: OptionSet {

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }

    public static let time = DisplayOptions(rawValue: 1 << 0) // 2022-04-16 18:13:07.222000-0700
    public static let level = DisplayOptions(rawValue: 1 << 1) // 💊

    public static let tag = DisplayOptions(rawValue: 1 << 2)
    public static let queue = DisplayOptions(rawValue: 1 << 3)
    public static let file = DisplayOptions(rawValue: 1 << 5)
    public static let function = DisplayOptions(rawValue: 1 << 4)

    /// "app finished launching"
    public static let none: DisplayOptions = []

    /// "2021-11-14 00:41:10.746000-0800 ℹ️ [io.chouti.ChouTi-Playground.macOS][AppDelegate.swift:13][applicationDidFinishLaunching(_:)] ➜ app finished launching"
    public static let noQueue: DisplayOptions = [.time, .level, .tag, .file, .function]

    /// "2021-11-14 00:41:45.180000-0800 ℹ️ ➜ app finished launching"
    public static let minimum: DisplayOptions = [.time, .level]

    /// "2021-11-14 00:41:57.891000-0800 ℹ️ [io.chouti.ChouTi-Playground.macOS] ➜ app finished launching"
    public static let concise: DisplayOptions = [.time, .level, .tag]

    /// "2021-11-14 00:45:27.639000-0800 ℹ️ [AppDelegate.swift:13] ➜ app finished launching"
    public static let conciseFile: DisplayOptions = [.time, .level, .file]

    /// "2021-11-14 00:44:22.698000-0800 ℹ️ [io.chouti.ChouTi-Playground.macOS][com.apple.main-thread][AppDelegate.swift:13][applicationDidFinishLaunching(_:)] ➜ app finished launching"
    public static let all: DisplayOptions = [.time, .level, .tag, .queue, .file, .function]
  }
}
