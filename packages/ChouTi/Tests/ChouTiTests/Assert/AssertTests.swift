//
//  AssertTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/4/26.
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

import ChouTiTest

@testable import ChouTi

class AssertTests: XCTestCase {

  override func tearDown() {
    super.tearDown()

    Assert.resetTestAssertionFailureHandler()
  }

  // MARK: - assert

  func test_assert_conditionTrue() {
    var failureCalled = false
    Assert.setTestAssertionFailureHandler { _, _, _, _, _ in
      failureCalled = true
    }

    ChouTi.assert(true, "This should not fail")

    expect(failureCalled) == false
  }

  func test_assert_conditionFalse() {
    var capturedMessage = ""
    var capturedMetadata: OrderedDictionary<String, String> = [:]
    var capturedFile: StaticString?
    var capturedLine: UInt?
    var capturedColumn: UInt?

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      capturedMessage = message
      capturedMetadata = metadata
      capturedFile = file
      capturedLine = line
      capturedColumn = column
    }

    // swiftformat:disable:next all
    ChouTi.assert(false, "Expected failure message", metadata: ["key1": "value1", "key2": "value2"])

    expect(capturedMessage) == "Expected failure message"
    expect(capturedMetadata) == ["key1": "value1", "key2": "value2"]
    expect(capturedFile).toNot(beNil())
    expect(capturedLine).toNot(beNil())
    expect(capturedColumn).toNot(beNil())
  }

  func test_assert_conditionFalse_defaultMessage() {
    var capturedMessage = ""

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      capturedMessage = message
    }

    // swiftformat:disable:next all
    ChouTi.assert(false)

    expect(capturedMessage) == ""
  }

  // MARK: - assertFailure

  func test_assertFailure() {
    var capturedMessage = ""
    var capturedMetadata: OrderedDictionary<String, String> = [:]
    var capturedFile: StaticString?
    var capturedLine: UInt?
    var capturedColumn: UInt?

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      capturedMessage = message
      capturedMetadata = metadata
      capturedFile = file
      capturedLine = line
      capturedColumn = column
    }

    ChouTi.assertFailure("Expected failure message", metadata: ["key1": "value1", "key2": "value2"])

    expect(capturedMessage) == "Expected failure message"
    expect(capturedMetadata) == ["key1": "value1", "key2": "value2"]
    expect(capturedFile).toNot(beNil())
    expect(capturedLine).toNot(beNil())
    expect(capturedColumn).toNot(beNil())
  }

  func test_assertFailure_defaultMessage() {
    var capturedMessage = ""
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      capturedMessage = message
    }

    ChouTi.assertFailure()
    expect(capturedMessage) == ""
  }

  // MARK: - Multiple Assertions

  func test_multipleAssertions() {
    var callCount = 0
    var messages: [String] = []

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      callCount += 1
      messages.append(message)
    }

    ChouTi.assertFailure("First failure")
    ChouTi.assertFailure("Second failure")
    ChouTi.assertFailure("Third failure")

    expect(callCount) == 3
    expect(messages) == ["First failure", "Second failure", "Third failure"]
  }

  // MARK: - Metadata Formatting

  func test_makeMetadataDescription_empty() {
    let description = makeMetadataDescription(metadata: [:])
    expect(description) == ""
  }

  func test_makeMetadataDescription_singleItem() {
    let description = makeMetadataDescription(metadata: ["key": "value"])
    expect(description) == """

    ----------------------------------------------------------------------------------------------------------------------
    📝 Metadata:
    - key: value
    """
  }

  func test_makeMetadataDescription_multipleItems() {
    let description = makeMetadataDescription(metadata: ["key1": "value1", "key2": "value2", "key3": "value3"])
    expect(description) == """

    ----------------------------------------------------------------------------------------------------------------------
    📝 Metadata:
    - key1: value1
    - key2: value2
    - key3: value3
    """
  }

  // MARK: - Error Logging

  func test_writeError() {
    // get the documents directory
    guard let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
      fail("Failed to get documents directory")
      return
    }

    let errorFolderURL = documentsURL.appendingPathComponent("assertion_failures")

    // clean up any existing error folder before test
    if FileManager.default.fileExists(atPath: errorFolderURL.path) {
      try? FileManager.default.removeItem(at: errorFolderURL)
    }

    // verify the folder doesn't exist yet
    expect(FileManager.default.fileExists(atPath: errorFolderURL.path)) == false

    // call writeError
    writeError(message: "Test error message", file: "TestFile.swift", line: 100, column: 101, function: "testFunction()")
    writeError(message: "Test error message 2", file: "TestFile2.swift", line: 200, column: 201, function: "testFunction2()")

    // verify the folder was created
    expect(FileManager.default.fileExists(atPath: errorFolderURL.path)) == true

    // verify a log file was created
    guard var files = try? FileManager.default.contentsOfDirectory(at: errorFolderURL, includingPropertiesForKeys: nil) else {
      fail("Failed to read error folder contents")
      return
    }

    expect(files.count) == 2

    // sort files by creation date
    files = files.sorted { file1, file2 in
      let attributes1 = try? FileManager.default.attributesOfItem(atPath: file1.path)
      let attributes2 = try? FileManager.default.attributesOfItem(atPath: file2.path)
      let creationDate1 = attributes1?[.creationDate] as? Date
      let creationDate2 = attributes2?[.creationDate] as? Date
      return creationDate1?.compare(creationDate2 ?? Date()) == .orderedAscending
    }

    // first file
    do {
      let fileURL = try files.first.unwrap()
      // Check filename matches timestamp format: <seconds>.<microseconds>.log
      // Example: 1767555293.561254.log
      let filename = fileURL.lastPathComponent
      let filenamePattern = #"^\d+\.\d+\.log$"#
      let filenameRegex = try NSRegularExpression(pattern: filenamePattern)
      let filenameRange = NSRange(filename.startIndex ..< filename.endIndex, in: filename)
      expect(filenameRegex.firstMatch(in: filename, range: filenameRange)).toNot(beNil())

      // Check content matches format: <timestamp> [<thread>][<file>:<line>:<column>][<function>] ➜ <message>
      // Example: 2026-01-04 11:24:01.567000-0800 [com.apple.main-thread][TestFile.swift:100:101][testFunction()] ➜ Test error message
      let content = try String(contentsOf: fileURL, encoding: .utf8)

      let contentPattern = "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+[+-]\\d{4} \\[com.apple.main-thread\\]\\[TestFile\\.swift\\:100\\:101\\]\\[testFunction\\(\\)\\] ➜ Test error message"
      let contentRegex = try NSRegularExpression(pattern: contentPattern, options: [])
      let contentRange = NSRange(content.startIndex ..< content.endIndex, in: content)
      expect(contentRegex.firstMatch(in: content, range: contentRange)).toNot(beNil())
    } catch {
      fail("Failed to read first file: \(error)")
    }

    // second file
    do {
      let fileURL = try files.last.unwrap()
      // Check filename matches timestamp format: <seconds>.<microseconds>.log
      // Example: 1767555293.561254.log
      let filename = fileURL.lastPathComponent
      let filenamePattern = #"^\d+\.\d+\.log$"#
      let filenameRegex = try NSRegularExpression(pattern: filenamePattern)
      let filenameRange = NSRange(filename.startIndex ..< filename.endIndex, in: filename)
      expect(filenameRegex.firstMatch(in: filename, range: filenameRange)).toNot(beNil())

      // Check content matches format: <timestamp> [<thread>][<file>:<line>:<column>][<function>] ➜ <message>
      // Example: 2026-01-04 11:24:01.567000-0800 [com.apple.main-thread][TestFile2.swift:200:201][testFunction2()] ➜ Test error message 2
      let content = try String(contentsOf: fileURL, encoding: .utf8)
      let contentPattern = "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+[+-]\\d{4} \\[com.apple.main-thread\\]\\[TestFile2\\.swift\\:200\\:201\\]\\[testFunction2\\(\\)\\] ➜ Test error message 2"
      let contentRegex = try NSRegularExpression(pattern: contentPattern, options: [])
      let contentRange = NSRange(content.startIndex ..< content.endIndex, in: content)
      expect(contentRegex.firstMatch(in: content, range: contentRange)).toNot(beNil())
    } catch {
      fail("Failed to read second file: \(error)")
    }
    // clean up after test
    try? FileManager.default.removeItem(at: errorFolderURL)
  }
}
