//
//  DeviceTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/19/24.
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

#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

import ChouTiTest

import ChouTi

final class DeviceTests: XCTestCase {

  func testDeviceType() {
    #if os(macOS)
    expect(Device.deviceType) == .mac
    #elseif os(iOS)
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      expect(Device.deviceType) == .phone
    case .pad:
      expect(Device.deviceType) == .pad
    case .unspecified:
      fail("Unsupported device type")
    case .tv:
      fail("Unsupported device type")
    case .carPlay:
      fail("Unsupported device type")
    case .mac:
      fail("Unsupported device type")
    case .vision:
      break
    @unknown default:
      fail("Unsupported device type")
    }
    #elseif os(visionOS)
    #elseif os(tvOS)
    expect(Device.deviceType) == .tv
    #elseif os(watchOS)
    expect(Device.deviceType) == .watch
    #else
    fail("Unsupported device type")
    #endif
  }

  #if os(macOS)
  func testVersionString() {
    let versionString = Device.versionString
    expect(versionString.isEmpty) == false
    expect(versionString.contains(".")) == true
  }

  func testDeviceName() {
    let deviceName = Device.deviceName
    expect(deviceName) != nil
    expect(try deviceName.unwrap().isEmpty) == false
  }

  func testModelIdentifier() {
    let modelIdentifier = Device.modelIdentifier()
    expect(modelIdentifier) != nil
    expect(try modelIdentifier.unwrap().contains(",")) == true
  }

  func testHasNotch() {
    _ = Device.hasNotch() // just test the method exists
    DeviceTests.checkIfMacNotchModelsNeedUpdate()
  }
  #endif

  func testFreeDiskSpaceInBytes() {
    let freeDiskSpace = Device.freeDiskSpaceInBytes
    expect(freeDiskSpace).to(beGreaterThan(0))
  }

  func testUUID() throws {
    try expect(Device.uuid().unwrap().isEmpty) == false

    // test UUID doesn't change
    let uuid1 = try Device.uuid().unwrap()
    let uuid2 = try Device.uuid().unwrap()
    expect(uuid1) == uuid2
  }
}

private extension DeviceTests {

  /// Check if the Mac notch models need to be updated.
  ///
  /// This method will check if the Mac notch models need to be updated by checking the published date of the Apple Support page.
  /// If the published date is after the last checked date, it will assert failure and prompt to update the Mac notch models.
  private static func checkIfMacNotchModelsNeedUpdate() {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
      await checkMacNotchModelsUpdateAsync()
      semaphore.signal()
    }
    semaphore.wait()
  }

  private static func checkMacNotchModelsUpdateAsync() async {
    let MacBookProURL = URL(string: "https://support.apple.com/en-us/108052")! // swiftlint:disable:this force_unwrapping
    let MacBookAirURL = URL(string: "https://support.apple.com/en-us/102869")! // swiftlint:disable:this force_unwrapping

    do {
      for url in [MacBookProURL, MacBookAirURL] {
        try await checkAppleSupportPageUpdatedDate(for: url)
      }
    } catch {
      fail("Failed to check for Mac notch model updates: \(error)")
    }
  }

  private static func checkAppleSupportPageUpdatedDate(for url: URL) async throws {
    // get the published date from the Apple Support page
    let htmlContent = try await fetchHTMLContent(from: url)
    guard let publishedDate = try parsePublishedDate(from: htmlContent) else {
      throw RuntimeError.reason("Could not parse published date from Apple Support page")
    }

    // the last checked date
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2025
    components.month = 9
    components.day = 28
    guard let lastCheckedDate = calendar.date(from: components) else {
      throw RuntimeError.reason("Failed to create date")
    }

    // check if the published date is after the last checked date
    if publishedDate > lastCheckedDate {
      fail("Apple Support page has been updated at \(publishedDate). Please update the Mac notch models.")
    }
    print("Apple Support page (\(url)) was updated on: \(publishedDate)")
  }

  private static func fetchHTMLContent(from url: URL) async throws -> String {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw RuntimeError.reason("Failed to fetch content from \(url)")
    }
    guard let htmlString = String(data: data, encoding: .utf8) else {
      throw RuntimeError.reason("Failed to decode HTML content")
    }
    return htmlString
  }

  private static func parsePublishedDate(from htmlContent: String) throws -> Date? {
    // Pattern to match: <time datetime="..." itemprop="datePublished">April 01, 2025</time>
    // or <div class="mod-date">...<time ...>April 01, 2025</time>...</div>

    let patterns = [
      // Match the time element with datePublished
      #"<time[^>]*itemprop="datePublished"[^>]*>([^<]+)</time>"#,
      // Match time element in mod-date div
      #"<div[^>]*class="mod-date"[^>]*>.*?<time[^>]*>([^<]+)</time>"#,
      // Generic published date pattern
      #"Published Date:.*?<time[^>]*>([^<]+)</time>"#,
      // Fallback pattern for just the date text
      #"Published Date:[^>]*([A-Za-z]+ \d{1,2}, \d{4})"#,
    ]

    for pattern in patterns {
      if let dateString = extractFirstMatch(from: htmlContent, pattern: pattern, groupIndex: 1) {
        let cleanedDateString = cleanDateString(dateString)
        if let date = parseDate(from: cleanedDateString) {
          return date
        }
      }
    }

    return nil
  }

  private static func extractFirstMatch(from text: String, pattern: String, groupIndex: Int = 1) -> String? {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
      return nil
    }
    let range = NSRange(text.startIndex..., in: text)

    if let match = regex.firstMatch(in: text, options: [], range: range) {
      let groupRange = match.range(at: groupIndex)
      if groupRange.location != NSNotFound,
         let matchRange = Range(groupRange, in: text)
      {
        return String(text[matchRange])
      }
    }
    return nil
  }

  private static func cleanDateString(_ dateString: String) -> String {
    // Remove HTML entities and extra whitespace
    return dateString
      .replacingOccurrences(of: "&nbsp;", with: " ")
      .replacingOccurrences(of: "&amp;", with: "&")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func parseDate(from dateString: String) -> Date? {
    // try multiple date formats that Apple might use
    let formats = [
      "MMMM dd, yyyy", // "April 01, 2025"
      "MMM dd, yyyy", // "Apr 01, 2025"
      "MMMM d, yyyy", // "April 1, 2025"
      "MMM d, yyyy", // "Apr 1, 2025"
      "yyyy-MM-dd", // "2025-04-01"
      "MM/dd/yyyy", // "04/01/2025"
    ]

    for format in formats {
      let formatter = DateFormatter()
      formatter.dateFormat = format
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone.current
      if let date = formatter.date(from: dateString) {
        return date
      }
    }
    return nil
  }
}
