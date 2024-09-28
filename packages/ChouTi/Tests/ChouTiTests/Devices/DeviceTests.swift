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

import ChouTiTest

#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

import ChouTi

final class DeviceTests: XCTestCase {

  func testDeviceType() {
    #if os(macOS)
    expect(Device.deviceType) == .mac
    #elseif os(iOS)
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      expect(Device.deviceType) == .iPhone
    case .pad:
      expect(Device.deviceType) == .iPad
    case .unspecified:
      fail("Unsupported device type")
    case .tv:
      fail("Unsupported device type")
    case .carPlay:
      fail("Unsupported device type")
    case .mac:
      fail("Unsupported device type")
    case .vision:
      fail("Unsupported device type")
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
