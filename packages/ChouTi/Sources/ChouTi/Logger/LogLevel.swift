//
//  LogLevel.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
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
