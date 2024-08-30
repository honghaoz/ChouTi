//
//  LogLevel.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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

/// Log level.
public enum LogLevel: String, Comparable {

  case debug
  case info
  case warning
  case error

  var emoji: String {
    switch self {
    case .debug:
      return "🧻" // 💬 🐽 💊 💡 🔘 🐛
    case .info:
      return "ℹ️"
    case .warning:
      return "⚠️"
    case .error:
      return "🛑"
    }
  }

  // MARK: - Comparable

  public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    switch (lhs, rhs) {
    case (.debug, .debug):
      return false
    case (.debug, _):
      return true
    case (.info, debug),
         (.info, info):
      return false
    case (.info, _):
      return true
    case (.warning, debug),
         (.warning, info),
         (.warning, warning):
      return false
    case (.warning, _):
      return true
    case (.error, _):
      return false
    }
  }
}
