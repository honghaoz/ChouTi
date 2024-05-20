//
//  Logger+DisplayOptions.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
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
