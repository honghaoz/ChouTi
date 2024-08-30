//
//  Logger.swift
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

/// A shared logger.
public let logger = Logger(tag: "chouti")

// MARK: - Logger

/**
 A logger.

 Example 1:
 ```swift
 #if DEBUG
 private lazy var logger = Logger(tag: "PollingMonitor", logLevel: .debug, displayOptions: .concise, isEnabled: true)
 #endif
 ```

 Example 2:
 ```swift
 import ChouTi

 let logger = Logger.shared

 final class Logger {

   static let shared = Logger()

   let `default` = ChouTi.Logger(tag: "default")
   let userSession = ChouTi.Logger(tag: "user-session")
   let api = ChouTi.Logger(tag: "api")

   func disable() {
     `default`.isEnabled = false
     userSession.isEnabled = false
     api.isEnabled = false
   }
 }
 ```
 */
public final class Logger: Hashable, CustomStringConvertible {

  /// The log tag.
  ///
  /// A tag is for "[Tag] XXX".
  public var tag: String?

  /// The log level.
  ///
  /// `.debug` -> all messages
  /// `.waning` -> waning and error
  public var logLevel: LogLevel

  /// The display options for logs.
  public var displayOptions: DisplayOptions

  /// The destinations for logs.
  public var destinations: [LogDestinationType]

  // TODO: support MetricKit
  // private lazy var metricsMonitor: MetricsMonitor = MetricsMonitor()

  /// If logger is enabled.
  public private(set) var isEnabled: Bool

  @usableFromInline
  let queue: DispatchQueue?

  /// Create a logger.
  ///
  /// - Parameters:
  ///   - tag: Logger tag.
  ///   - logLevel: Log level.
  ///   - displayOptions: The display options for logs.
  ///   - destinations: The destinations for logs.
  ///   - queue: The queue logger work on. If nil, use the current queue.
  ///   - isEnabled: If logger is enabled.
  public init(tag: String? = nil,
              logLevel: LogLevel = .debug,
              displayOptions: DisplayOptions = .all,
              destinations: [LogDestination] = [.standardOut],
              queue: DispatchQueue? = nil,
              isEnabled: Bool = true)
  {
    self.tag = tag
    self.logLevel = logLevel
    self.displayOptions = displayOptions
    self.queue = queue
    self.destinations = destinations
    self.isEnabled = isEnabled
  }

  /// Enable logger.
  @discardableResult
  public func enable() -> Self {
    isEnabled = true
    return self
  }

  /// Disable logger.
  @discardableResult
  public func disable() -> Self {
    isEnabled = false
    return self
  }

  /// Add a debug log.
  @inlinable
  @inline(__always)
  public func debug(_ message: String,
                    file: StaticString = #fileID,
                    line: UInt = #line,
                    column: UInt = #column,
                    function: StaticString = #function)
  {
    debug(LogMessage(message), file: file, line: line, column: column, function: function)
  }

  /// Add a debug log.
  @inlinable
  @inline(__always)
  public func debug(_ message: LogMessage = LogMessage(),
                    file: StaticString = #fileID,
                    line: UInt = #line,
                    column: UInt = #column,
                    function: StaticString = #function)
  {
    #if DEBUG
    guard isEnabled, logLevel <= .debug else {
      return
    }
    ChouTi_log(
      message,
      tag: tag,
      level: .debug,
      file: file,
      line: line,
      column: column,
      function: function,
      displayOptions: displayOptions,
      queue: queue,
      destinations: destinations
    )
    #endif
  }

  /// Add an info log.
  @inlinable
  @inline(__always)
  public func info(_ message: String,
                   file: StaticString = #fileID,
                   line: UInt = #line,
                   column: UInt = #column,
                   function: StaticString = #function)
  {
    info(LogMessage(message), file: file, line: line, column: column, function: function)
  }

  /// Add an info log.
  @inlinable
  @inline(__always)
  public func info(_ message: LogMessage = LogMessage(),
                   file: StaticString = #fileID,
                   line: UInt = #line,
                   column: UInt = #column,
                   function: StaticString = #function)
  {
    guard isEnabled, logLevel <= .info else {
      return
    }
    ChouTi_log(
      message,
      tag: tag,
      level: .info,
      file: file,
      line: line,
      column: column,
      function: function,
      displayOptions: displayOptions,
      queue: queue,
      destinations: destinations
    )
  }

  /// Add a warning log.
  @inlinable
  @inline(__always)
  public func warning(_ message: String,
                      file: StaticString = #fileID,
                      line: UInt = #line,
                      column: UInt = #column,
                      function: StaticString = #function)
  {
    warning(LogMessage(message), file: file, line: line, column: column, function: function)
  }

  /// Add a warning log.
  @inlinable
  @inline(__always)
  public func warning(_ message: LogMessage = LogMessage(),
                      file: StaticString = #fileID,
                      line: UInt = #line,
                      column: UInt = #column,
                      function: StaticString = #function)
  {
    guard isEnabled, logLevel <= .warning else {
      return
    }
    ChouTi_log(
      message,
      tag: tag,
      level: .warning,
      file: file,
      line: line,
      column: column,
      function: function,
      displayOptions: displayOptions,
      queue: queue,
      destinations: destinations
    )
  }

  /// Add an error log.
  @inlinable
  @inline(__always)
  public func error(_ message: String,
                    file: StaticString = #fileID,
                    line: UInt = #line,
                    column: UInt = #column,
                    function: StaticString = #function)
  {
    error(LogMessage(message), file: file, line: line, column: column, function: function)
  }

  /// Add an error log.
  @inlinable
  @inline(__always)
  public func error(_ message: LogMessage = LogMessage(),
                    file: StaticString = #fileID,
                    line: UInt = #line,
                    column: UInt = #column,
                    function: StaticString = #function)
  {
    guard isEnabled, logLevel <= .error else {
      return
    }
    ChouTi_log(
      message,
      tag: tag,
      level: .error,
      file: file,
      line: line,
      column: column,
      function: function,
      displayOptions: displayOptions,
      queue: queue,
      destinations: destinations
    )
  }

  // MARK: - Hashable

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  // MARK: - Equatable

  public static func == (lhs: Logger, rhs: Logger) -> Bool {
    lhs === rhs
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    if let tag {
      return "Logger<\(rawPointer(self))>(\(tag))"
    } else {
      return "Logger<\(rawPointer(self))>"
    }
  }
}

// MARK: - Private

@usableFromInline
func ChouTi_log(_ message: LogMessage,
                tag: String? = nil,
                level: LogLevel,
                file: StaticString,
                line: UInt,
                column: UInt,
                function: StaticString,
                displayOptions: Logger.DisplayOptions,
                queue: DispatchQueue?,
                destinations: [LogDestinationType])
{
  let printWork = {
    var components: [String] = []
    if displayOptions.contains(.time) {
      let timeString = DateFormatter.logger.string(from: Date())
      components.append(timeString)
    }
    if displayOptions.contains(.level) {
      components.append(level.emoji)
    }
    let part1 = components.joined(separator: " ")

    var part2 = ""
    if displayOptions.contains(.tag), let tag {
      part2 += "[\(tag)]"
    }
    #if DEBUG
    if displayOptions.contains(.queue) {
      part2 += "[\(DispatchQueue.currentQueueLabelOrNil ?? "Unknown")]"
    }
    #endif
    if displayOptions.contains(.file) {
      let fileName = file.description.components(separatedBy: "/").last ?? "Unknown"
      part2 += "[\(fileName):\(line):\(column)]"
    }
    if displayOptions.contains(.function) {
      part2 += "[\(function)]"
    }

    let aggregated = [part1, part2].filter { !$0.isEmpty }.joined(separator: " ")

    let logText: String = {
      if aggregated.isEmpty {
        return message.materializedString()
      } else {
        return aggregated + " ➜ \(message.materializedString())"
      }
    }()

    for destination in destinations {
      destination.write(logText)
    }
  }

  if let queue {
    queue.asyncIfNeeded {
      printWork()
    }
  } else {
    printWork()
  }
}

private extension DateFormatter {

  static let logger: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
    formatter.locale = .enUSPOSIX
    return formatter
  }()
}
