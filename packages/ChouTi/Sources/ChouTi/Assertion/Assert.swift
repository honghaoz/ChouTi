//
//  Assert.swift
//  ChouTi
//
//  Created by Honghao Zhang on 7/18/21.
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

/// Run test with `swift test -Xswiftc -DTEST` to enable `import XCTest`.
#if TEST
import XCTest
#endif

#if DEBUG
public enum Assert {

  /// If assertions are enabled. Set this flag to `false` to disable assertions.
  public static var isAssertEnabled = true

  /// If should write assertion failure logs to `~/Documents/assertion_failures`.
  public static var shouldWriteErrorLog = true

  // MARK: - Testing

  /// The test assertion failure type.
  public typealias TestAssertionFailureHandler = (_ message: String, _ metadata: OrderedDictionary<String, String>, _ file: StaticString, _ line: UInt, _ column: UInt) -> Void

  /// The assertion failure handler for testing.
  ///
  /// Default handler will fail the test.
  /// You can call `setTestAssertionFailureHandler(_:)` to set your own handler to customize the behavior.
  /// Call `resetTestAssertionFailureHandler()` to reset the handler to the default handler.
  ///
  /// Example:
  /// ```swift
  /// Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
  ///   expect(message) == "assertion failure message"
  /// }
  /// ```
  public static var testAssertionFailureHandler: TestAssertionFailureHandler? = __defaultTestAssertionFailureHandler

  /// Set the test assertion failure handler.
  ///
  /// Example:
  /// ```swift
  /// Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
  ///   expect(message) == "assertion failure message"
  /// }
  /// ```
  ///
  /// - Parameter handler: The test assertion failure handler.
  public static func setTestAssertionFailureHandler(_ handler: TestAssertionFailureHandler?) {
    testAssertionFailureHandler = handler
  }

  /// Reset the test assertion failure handler to the default handler.
  public static func resetTestAssertionFailureHandler() {
    testAssertionFailureHandler = __defaultTestAssertionFailureHandler
  }

  static let __defaultTestAssertionFailureHandler: TestAssertionFailureHandler? = { message, metadata, file, line, column in
    let message = """
    🛑 Assertion Failure 🛑 💾 Source: \(file):\(line):\(column), 🗯️ Message: "\(message)", 📝 metadata: \(metadata)
    """
    #if TEST
    XCTFail(message, file: file, line: line)
    #else
    assertionFailure(message)
    #endif
  }

  public static let __logDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
    formatter.locale = .enUSPOSIX
    return formatter
  }()
}
#endif

#if DEBUG
@usableFromInline
let ChouTi_AssertLogger = Logger(logLevel: .debug, displayOptions: [.time, .queue, .function, .file])
#endif

@inlinable
@inline(__always)
public func assert(_ condition: @autoclosure () -> Bool,
                   _ message: @autoclosure () -> String = String(),
                   metadata: @autoclosure () -> OrderedDictionary<String, String> = [:],
                   failureBlock: BlockVoid? = nil,
                   file: StaticString = #fileID,
                   line: UInt = #line,
                   column: UInt = #column,
                   function: StaticString = #function)
{
  #if DEBUG
  if !condition() {
    assertFailure(message(), metadata: metadata(), failureBlock: failureBlock, file: file, line: line, column: column, function: function)
  }
  #endif
}

@inlinable
@inline(__always)
public func assertFailure(_ message: @autoclosure () -> String = String(),
                          metadata: @autoclosure () -> OrderedDictionary<String, String> = [:],
                          failureBlock: BlockVoid? = nil,
                          file: StaticString = #fileID,
                          line: UInt = #line,
                          column: UInt = #column,
                          function: StaticString = #function)
{
  #if DEBUG
  if Thread.isRunningXCTest {
    Assert.testAssertionFailureHandler?(message(), metadata(), file, line, column)
  } else {

    let message: LogMessage = """
    🛑 Assertion Failure 🛑
    ----------------------------------------------------------------------------------------------------------------------
    🗯️ Message: "\(message())"\(makeMetadataDescription(metadata: metadata()))
    ----------------------------------------------------------------------------------------------------------------------
    🥞 Stack Trace:
    \(Thread.callStackSymbolsString(dropFirst: 2))
    """

    ChouTi_AssertLogger.debug(message, file: file, line: line, column: column, function: function)
    failureBlock?()

    if Assert.shouldWriteErrorLog {
      writeError(message: message.materializedString(), file: file, line: line, column: column, function: function)
    }

    if Assert.isAssertEnabled, isDebuggingUsingXcode {
      raise(SIGABRT)
    }
  }
  #endif
}

#if DEBUG
@inlinable
@inline(__always)
func makeMetadataDescription(metadata: OrderedDictionary<String, String>) -> String {
  guard !metadata.isEmpty else {
    return ""
  }

  var string = """

  ----------------------------------------------------------------------------------------------------------------------
  📝 Metadata:

  """

  for key in metadata.keys.sorted() {
    let value = metadata[key]! // swiftlint:disable:this force_unwrapping
    string += "- \(key): \(value)\n"
  }
  // remove last newline
  if !string.isEmpty {
    string.removeLast()
  }
  return string
}

@inlinable
@inline(__always)
func writeError(message: String,
                file: StaticString = #fileID,
                line: UInt = #line,
                column: UInt = #column,
                function: StaticString = #function)
{
  // TODO: [iOS] should show the error to UI

  do {
    let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    // create errors folder
    let errorFolder = documents.appendingPathComponent("assertion_failures")
    try FileManager.default.createDirectory(at: errorFolder, withIntermediateDirectories: true, attributes: nil)

    // create error file
    let now = Date()
    let errorFile = errorFolder.appendingPathComponent("\(now.timeIntervalSince1970).log")
    guard FileManager.default.createFile(atPath: errorFile.path, contents: nil, attributes: nil) else {
      ChouTi_AssertLogger.error("unable to create assertion error log file: \(errorFile.path)")
      return
    }

    let part1 = Assert.__logDateFormatter.string(from: now)

    let fileName = file.description.components(separatedBy: "/").last ?? "Unknown"
    let part2 = "[\(DispatchQueue.currentQueueLabelOrNil ?? "Unknown")][\(fileName):\(line):\(column)][\(function)]"

    let logText: String = "\(part1) \(part2) ➜ \(message)"

    // write to file
    try logText.write(to: errorFile, atomically: true, encoding: .utf8)

    print("----------------------------------------------------------------------------------------------------------------------\n💾 Error Log File:\n\(errorFile.path)\n----------------------------------------------------------------------------------------------------------------------")
  } catch {
    ChouTi_AssertLogger.error("write file error: [\(file):\(line):\(column)][\(function)] \(message)")
  }
}
#endif

/*
 References:
 - https://developer.apple.com/swift/blog/?id=4
 - https://www.pointfree.co/blog/posts/70-unobtrusive-runtime-warnings-for-libraries
 - https://dsa.cs.tsinghua.edu.cn/oj/static/unix_signal.html
 */
