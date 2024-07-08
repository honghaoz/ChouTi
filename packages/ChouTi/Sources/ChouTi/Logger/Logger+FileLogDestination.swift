//
//  Logger+FileLogDestination.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension LogDestination {

  /// Create a file log destination at ~/Documents/logs/<fileName>.
  /// - Parameter fileName: The log file name.
  /// - Returns: A file log destination.
  static func file(_ fileName: String) -> LogDestination {
    Logger.FileLogDestination(folder: nil, fileName: fileName, maxSizeInBytes: nil).asLogDestination()
  }

  /// Create a file log destination.
  /// - Parameters:
  ///   - folder: The folder to store log files, default is "~/Documents/logs".
  ///   - fileName: The log file name.
  ///   - maxSizeInBytes: The max log file size in bytes, default is 50 MB.
  /// - Returns: A file log destination.
  static func file(folder: URL? = nil, fileName: String, maxSizeInBytes: UInt64? = nil) -> LogDestination {
    Logger.FileLogDestination(folder: folder, fileName: fileName, maxSizeInBytes: maxSizeInBytes).asLogDestination()
  }
}

public extension Logger {

  /**
   Create a file log destination.

   Logs can write to a file.

   Examples:
   ```swift
   // with bundle identifier
   Logger.FileLogDestination(fileName: "\(Bundle.bundleIdentifier).app.log")
   // simple name
   Logger.FileLogDestination(fileName: "io.chouti.magic-app.app.log"))

   // static method
   .file("\(Bundle.bundleIdentifier, default: "Unknown").app.log"),
   ```
   */
  final class FileLogDestination: LogDestinationType {

    /// The folder to store log files.
    private let logFolder: URL

    /// Current log file location.
    private let logFile: URL

    /// The max log file size.
    public let maxSizeInBytes: UInt64

    // TODO: support file rotation
    //
    // LOGFILE ROTATION
    // ho many bytes should a log file have until it is rotated?
    // default is 5 MB. Just is used if logFileAmount > 1
    //
    /// Number of log files used in rotation, default is 1 which deactivates file rotation
    // public let maxLogFilesCount: UInt // 1
    // private func rotateFileIfNeeded() { }

    /// Current log file size.
    private var logFileSize: UInt64 = 0

    /// The file size to trim.
    private let trimSize: UInt64

    /// The minimum required disk space to write logs.
    private let minimumRequiredDiskSpace: UInt64 = 524288000 // 500 * 1024 * 1024 (500 MB)

    private let queue = DispatchQueue.make(label: "io.chouti.ChouTi.FileLogDestination")

    /// Create a file log destination.
    /// - Parameters:
    ///   - folder: The folder to store log files. Default is "~/Documents/logs"
    ///   - fileName: The log file name.
    ///   - maxSizeInBytes: The max log file size in bytes, default is 5 MB.
    public init(folder: URL? = nil, fileName: String, maxSizeInBytes: UInt64? = nil) {
      if let logFolder = folder ?? Constants.logsFolder {
        self.logFolder = logFolder
      } else {
        ChouTi.assertFailure("Log folder is unavailable.", metadata: ["folder": String(describing: folder ?? Constants.logsFolder)])
        self.logFolder = URL(fileURLWithPath: NSTemporaryDirectory())
      }
      self.logFile = self.logFolder.appendingPathComponent(fileName)
      self.maxSizeInBytes = maxSizeInBytes ?? 52428800 // 50 * 1024 * 1024 (50 MB)

      let minTrimSize: UInt64 = 102400 // 100 * 1024 (100 KB)
      if self.maxSizeInBytes < minTrimSize {
        self.trimSize = self.maxSizeInBytes / 100
      } else {
        self.trimSize = minTrimSize
      }

      do {
        try prepareFile()
      } catch {
        ChouTi.assertFailure("Failed to prepare log file", metadata: ["error": "\(error)"])
      }
    }

    private func prepareFile() throws {
      if !FileManager.default.fileExists(atPath: logFile.path) {
        try FileManager.default.createDirectory(atPath: logFolder.path, withIntermediateDirectories: true, attributes: nil)
        guard FileManager.default.createFile(atPath: logFile.path, contents: nil, attributes: nil) else {
          ChouTi.assertFailure("Unable to create the log file", metadata: ["file": logFile.path])
          throw Error.logFileCreationFailed(logFile)
        }
      }

      #if DEBUG
      DispatchQueue.once(token: ObjectIdentifier(self)) {
        // Sandboxed app uses: ~/Library/Containers/TheApp/Data/Documents
        // Non Sandboxed app uses: ~/Documents
        // Root app uses: /var/root/Documents
        print("📃 [Logger][\(typeName(self))] log file location: \(logFile.path)")
      }
      #endif
    }

    public func write(_ string: String) {
      queue.async { [weak self] in
        self?._write(string)
      }
    }

    private func _write(_ string: String) {
      // Make sure we have enough disk space left. This prevents a crash due to a lack of space.
      guard Device.freeDiskSpaceInBytes > minimumRequiredDiskSpace else {
        #if DEBUG
        print("📃 [Logger][\(typeName(self))] ⚠️ not enough disk space, left: \(Device.freeDiskSpaceInBytes) bytes.")
        #endif
        return
      }

      let fileManager = FileManager.default
      let coordinator = NSFileCoordinator(filePresenter: nil)
      var error: NSError?
      coordinator.coordinate(writingItemAt: logFile, error: &error) { [weak self] url in
        guard fileManager.fileExistsAndIsFile(atPath: url.path) else {
          ChouTi.assertFailure("expect a log file at: \(url)")
          return
        }

        do {
          #if !os(macOS)
          // https://pspdfkit.com/blog/2017/how-to-use-ios-data-protection/
          var attributes = try fileManager.attributesOfItem(atPath: url.path)
          attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
          try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
          #endif

          let fileHandle = try FileHandle(forWritingTo: url)
          let data = Data((string + "\n").utf8)
          if #available(OSX 10.15.4, iOS 13.4, watchOS 6.0, tvOS 13.4, *) {
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: data)
          } else {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
          }

          // seems like no need to do this:
          // if syncAfterEachWrite {
          //   fileHandle.synchronizeFile() // synchronize()
          // }

          self.assert()?.logFileSize = try {
            if #available(OSX 10.15.4, iOS 13.4, *) {
              return try fileHandle.offset()
            } else {
              return fileHandle.offsetInFile
            }
          }()

          fileHandle.closeFile()
          try self.assert()?.trimLinesIfNecessary()
        } catch {
          ChouTi.assertFailure("error while write log file", metadata: ["error": "\(error)"])
        }
      }
    }

    /// Trim log file if current log file is too big.
    private func trimLinesIfNecessary() throws {
      guard logFileSize > maxSizeInBytes else {
        return
      }

      // not exactly sure why ".mappedIfSafe", but seems like a reasonable option.
      // https://stackoverflow.com/questions/36809449/which-nsdatareadingoptions-should-be-used-when-reading-a-local-file
      guard var data = try? Data(contentsOf: logFile, options: .mappedIfSafe), !data.isEmpty else {
        ChouTi.assertFailure("Trimming the current log file failed")
        return
      }

      let newline = Data("\n".utf8)

      var position = 0
      // trim line by line until hit the trim size
      while (logFileSize - UInt64(position)) > (maxSizeInBytes - trimSize) {
        guard let range = data.firstRange(of: newline, in: position ..< data.count) else {
          break
        }
        position = range.startIndex.advanced(by: 1) // trim one line
      }

      #if DEBUG
      print("📃 [Logger][\(typeName(self))] current log file size: \(logFileSize) bytes, trimming log file by: \(position)")
      #endif

      logFileSize -= UInt64(position)
      data.removeSubrange(0 ..< position)

      try data.write(to: logFile, options: .atomic)
    }

    // MARK: - Constants

    private enum Constants {

      static let logsFolder = FileManager.userDocuments?.appendingPathComponent("logs")
    }
  }

  // MARK: - Error

  enum Error: Swift.Error {

    case logFolderUnavailable
    case logFileCreationFailed(URL)
  }
}

private extension FileManager {

  static var userDocuments: URL? {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    ChouTi.assert(paths.count == 1)
    return paths.first
  }

  func fileExistsAndIsFile(atPath path: String) -> Bool {
    var isDirectory: ObjCBool = false
    if fileExists(atPath: path, isDirectory: &isDirectory) {
      return !isDirectory.boolValue
    } else {
      return false
    }
  }
}

//  References:
//  - https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/Sources/FileDestination.swift
//  - https://github.com/WeTransfer/Diagnostics/blob/master/Sources/Logging/DiagnosticsLogger.swift
