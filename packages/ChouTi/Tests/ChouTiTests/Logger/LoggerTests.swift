//
//  LoggerTests.swift
//
//  Created by Honghao Zhang on 5/20/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

@testable import ChouTi

final class LoggerTests: XCTestCase {

  func test_defaultInit() {
    let logger = Logger()
    expect(logger.tag) == nil
    expect(logger.logLevel) == .debug
    expect(logger.displayOptions) == .all
    expect(logger.destinations.count) == 1
    expect(try (logger.destinations.first.unwrap() as? LogDestination)?.wrapped is ChouTi.Logger.StandardOutLogDestination) == true
    expect(logger.isEnabled) == true
    expect(logger.queue) == nil
  }

  func test_enable() {
    let logger = Logger()
    logger.enable()
    expect(logger.isEnabled) == true
    logger.disable()
    expect(logger.isEnabled) == false
  }

  func test_logs() throws {
    let logger = Logger(tag: "tag")
    let destination = TestLogDestination()
    logger.destinations = [destination]

    do {
      destination.logs.removeAll()
      logger.debug("log1")

      // ["2024-06-03 19:24:43.090000-0700 🧻 [com.apple.main-thread][LoggerTests.swift:37:17][test_logs()] ➜ log1"]
      let logs = destination.logs
      expect(logs.count) == 1
      let log = try logs.first.unwrap()
      let components = log.components(separatedBy: " ")
      if components.count == 6 {
        expect(components[0].count) == 10 // 2024-06-03
        expect(components[1].count) == 20 // 19:24:43.090000-0700
        expect(components[2]) == "🧻"
        expect(components[3]) == "[tag][com.apple.main-thread][LoggerTests.swift:40:19][test_logs()]"
        expect(components[4]) == "➜"
        expect(components[5]) == "log1"
      } else {
        fail("log components.count == \(logs.count)")
      }
    }

    do {
      destination.logs.removeAll()
      let value: String? = "some"
      let nilValue: String? = nil
      logger.debug(
        LogMessage("value: \(value, default: "fallback"), value2: \(nilValue, default: "fallback")")
      )

      // ["2024-06-03 19:24:43.090000-0700 🧻 [com.apple.main-thread][LoggerTests.swift:37:17][test_logs()] ➜ log1"]
      let logs = destination.logs
      expect(logs.count) == 1
      let log = try logs.first.unwrap()
      let components = log.components(separatedBy: " ")
      if components.count == 9 {
        expect(components[0].count) == 10 // 2024-06-03
        expect(components[1].count) == 20 // 19:24:43.090000-0700
        expect(components[2]) == "🧻"
        expect(components[3]) == "[tag][com.apple.main-thread][LoggerTests.swift:63:19][test_logs()]"
        expect(components[4]) == "➜"
        expect(components[5]) == "value:"
        expect(components[6]) == "some,"
        expect(components[7]) == "value2:"
        expect(components[8]) == "fallback"
      } else {
        fail("log components.count == \(components.count)")
      }
    }

    do {
      destination.logs.removeAll()
      logger.displayOptions = .none
      logger.debug("log1")

      let logs = destination.logs
      expect(logs.count) == 1
      let log = try logs.first.unwrap()
      let components = log.components(separatedBy: " ")
      if components.count == 1 {
        expect(components[0]) == "log1"
      } else {
        fail("log components.count == \(logs.count)")
      }
    }
  }

  func test_logLevel() {
    let logger = Logger()
    let destination = TestLogDestination()
    logger.destinations = [destination]

    do {
      logger.logLevel = .warning

      logger.debug("debug")
      expect(destination.logs.isEmpty) == true

      logger.info("info")
      expect(destination.logs.isEmpty) == true

      logger.warning("warning")
      expect(destination.logs.count) == 1

      logger.error("error")
      expect(destination.logs.count) == 2
    }

    do {
      logger.logLevel = .debug
      destination.logs.removeAll()

      logger.debug("debug")
      expect(destination.logs.count) == 1

      logger.info("info")
      expect(destination.logs.count) == 2

      logger.warning("warning")
      expect(destination.logs.count) == 3

      logger.error("error")
      expect(destination.logs.count) == 4
    }

    do {
      logger.logLevel = .error
      destination.logs.removeAll()

      logger.debug("debug")
      expect(destination.logs.isEmpty) == true

      logger.info("info")
      expect(destination.logs.isEmpty) == true

      logger.warning("warning")
      expect(destination.logs.isEmpty) == true

      logger.error("error")
      expect(destination.logs.count) == 1
    }
  }

  func test_disabledLogger() {
    let logger = Logger()
    let destination = TestLogDestination()
    logger.destinations = [destination]

    logger.disable()

    logger.debug("debug")
    expect(destination.logs.isEmpty) == true

    logger.info("info")
    expect(destination.logs.isEmpty) == true

    logger.warning("warning")
    expect(destination.logs.isEmpty) == true

    logger.error("error")
    expect(destination.logs.isEmpty) == true
  }

  func test_queue() {
    let queue = DispatchQueue.make(label: "test")

    let logger = Logger(queue: queue)
    let destination = TestLogDestination()
    destination.assertQueue = queue
    logger.destinations = [destination]

    logger.debug("debug")
    expect(destination.logs).toEventuallyNot(beEmpty())
  }

  func test_fileDestination() throws {
    // remove log file if exists
    let logPath = "~/Documents/logs/test.log"
    if FileManager.default.fileExists(atPath: logPath) {
      try FileManager.default.removeItem(atPath: logPath)
    }

    let logger = Logger()
    let fileDestination = LogDestination.file("test.log")
    logger.destinations = [fileDestination]

    logger.debug("debug")
    logger.info("info")
    logger.warning("warning")
    logger.error("error")

    // Check log file at
    // ~/Documents/logs/test.log
    let logFolderURL = try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("logs")
    let logFileURL = logFolderURL.appendingPathComponent("test.log")

    let logFileContent = try String(contentsOf: logFileURL)
    let lines = logFileContent.components(separatedBy: "\n")
    if lines.count == 5 {
      // 2024-06-03 21:30:43.167000-0700 🧻 [com.apple.main-thread][LoggerTests.swift:197:17][test_fileDestination()] ➜ debug
      // 2024-06-03 21:30:43.235000-0700 ℹ️ [com.apple.main-thread][LoggerTests.swift:198:16][test_fileDestination()] ➜ info
      // 2024-06-03 21:30:43.254000-0700 ⚠️ [com.apple.main-thread][LoggerTests.swift:199:19][test_fileDestination()] ➜ warning
      // 2024-06-03 21:30:43.275000-0700 🛑 [com.apple.main-thread][LoggerTests.swift:200:17][test_fileDestination()] ➜ error
      expect(try lines[0].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} 🧻 \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination\\(\\)] ➜ debug"))) != nil
      expect(try lines[1].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} ℹ️ \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination\\(\\)] ➜ info"))) != nil
      expect(try lines[2].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} ⚠️ \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination\\(\\)] ➜ warning"))) != nil
      expect(try lines[3].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} 🛑 \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination\\(\\)] ➜ error"))) != nil
      expect(lines[4]) == ""
    } else {
      fail("lines.count == \(lines.count)")
    }

    // remove log file
    try FileManager.default.removeItem(at: logFileURL)

    // remove log folder if log folder is empty
    if FileManager.default.fileExists(atPath: logFolderURL.path) {
      // check if folder is empty
      let contents = try FileManager.default.contentsOfDirectory(atPath: logFolderURL.path)
      if contents.isEmpty {
        try FileManager.default.removeItem(at: logFolderURL)
      }
    }
  }

  func test_fileDestination_customFolder() throws {
    let logFolderURL = try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("custom-logs")
    let logFileURL = logFolderURL.appendingPathComponent("test.log")

    // remove log file if exists
    let logFilePath = logFileURL.path()
    if FileManager.default.fileExists(atPath: logFilePath) {
      try FileManager.default.removeItem(atPath: logFilePath)
    }

    let logger = Logger()

    let fileDestination = LogDestination.file(folder: logFolderURL, fileName: "test.log")
    logger.destinations = [fileDestination]

    logger.debug("debug")
    logger.info("info")
    logger.warning("warning")
    logger.error("error")

    let logFileContent = try String(contentsOf: logFileURL)
    let lines = logFileContent.components(separatedBy: "\n")
    if lines.count == 5 {
      // 2024-06-03 21:30:43.167000-0700 🧻 [com.apple.main-thread][LoggerTests.swift:197:17][test_fileDestination_customFolder()] ➜ debug
      // 2024-06-03 21:30:43.235000-0700 ℹ️ [com.apple.main-thread][LoggerTests.swift:198:16][test_fileDestination_customFolder()] ➜ info
      // 2024-06-03 21:30:43.254000-0700 ⚠️ [com.apple.main-thread][LoggerTests.swift:199:19][test_fileDestination_customFolder()] ➜ warning
      // 2024-06-03 21:30:43.275000-0700 🛑 [com.apple.main-thread][LoggerTests.swift:200:17][test_fileDestination_customFolder()] ➜ error
      expect(try lines[0].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} 🧻 \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination_customFolder\\(\\)] ➜ debug"))) != nil
      expect(try lines[1].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} ℹ️ \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination_customFolder\\(\\)] ➜ info"))) != nil
      expect(try lines[2].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} ⚠️ \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination_customFolder\\(\\)] ➜ warning"))) != nil
      expect(try lines[3].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} 🛑 \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination_customFolder\\(\\)] ➜ error"))) != nil
      expect(lines[4]) == ""
    } else {
      fail("lines.count == \(lines.count)")
    }

    // remove log file
    try FileManager.default.removeItem(at: logFileURL)

    // remove log folder if log folder is empty
    if FileManager.default.fileExists(atPath: logFolderURL.path) {
      // check if folder is empty
      let contents = try FileManager.default.contentsOfDirectory(atPath: logFolderURL.path)
      if contents.isEmpty {
        try FileManager.default.removeItem(at: logFolderURL)
      }
    }
  }

  func test_fileDestination_trim() throws {
    let logFolderURL = try FileManager.default
      .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      .appendingPathComponent("trim-logs")
    let logFileURL = logFolderURL.appendingPathComponent("test.log")

    // remove log file if exists
    let logFilePath = logFileURL.path()
    if FileManager.default.fileExists(atPath: logFilePath) {
      try FileManager.default.removeItem(atPath: logFilePath)
    }

    let logger = Logger()

    let fileDestination = LogDestination.file(folder: logFolderURL, fileName: "test.log", maxSizeInBytes: 200)
    logger.destinations = [fileDestination]

    logger.debug("debug") // 126 bytes
    logger.debug("debug2") // 252 bytes -> trim

    let logFileContent = try String(contentsOf: logFileURL)
    let lines = logFileContent.components(separatedBy: "\n")

    if lines.count == 2 {
      expect(try lines[0].wholeMatch(of: Regex("\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{6}-\\d{4} 🧻 \\[com.apple.main-thread\\]\\[LoggerTests.swift:\\d+:\\d+\\]\\[test_fileDestination_trim\\(\\)] ➜ debug2"))) != nil
      expect(lines[1]) == ""
    } else {
      fail("lines.count == \(lines.count)")
    }

    // remove log file
    try FileManager.default.removeItem(at: logFileURL)

    // remove log folder if log folder is empty
    if FileManager.default.fileExists(atPath: logFolderURL.path) {
      // check if folder is empty
      let contents = try FileManager.default.contentsOfDirectory(atPath: logFolderURL.path)
      if contents.isEmpty {
        try FileManager.default.removeItem(at: logFolderURL)
      }
    }
  }

  func test_Hashable() {
    let logger1 = Logger()
    let logger2 = Logger()
    let logger3 = Logger()
    expect(logger1.hashValue) == logger1.hashValue
    expect(logger1.hashValue) != logger2.hashValue
    expect(logger1.hashValue) != logger3.hashValue
  }

  func test_Equatable() {
    let logger1 = Logger()
    let logger2 = Logger()
    let logger3 = Logger()
    expect(logger1) == logger1
    expect(logger1) != logger2
    expect(logger1) != logger3
  }

  func test_CustomStringConvertible() throws {
    let logger = Logger()
    // Logger<0x0000600002df5080>
    expect(try logger.description.firstMatch(of: Regex("Logger<0x[0-9a-f]+>"))) != nil

    logger.tag = "tag"
    // Logger<0x0000600002df5080>(tag)
    expect(try logger.description.firstMatch(of: Regex("Logger<0x[0-9a-f]+>\\(tag\\)"))) != nil
  }
}

private class TestLogDestination: LogDestinationType {

  var assertQueue: DispatchQueue?

  var logs: [String] = []

  func write(_ string: String) {
    logs.append(string)
    if let assertQueue = assertQueue {
      expect(DispatchQueue.isOnQueue(assertQueue)) == true
    }
  }
}
