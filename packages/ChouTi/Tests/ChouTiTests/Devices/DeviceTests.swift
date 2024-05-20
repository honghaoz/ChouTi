//
//  DeviceTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
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
    if UIDevice.current.userInterfaceIdiom == .pad {
      expect(Device.deviceType) == .iPad
    } else {
      expect(Device.deviceType) == .iPhone
    }
    #else
    fail("Unknown device type")
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

  // Test free disk space
  func testFreeDiskSpaceInBytes() {
    let freeDiskSpace = Device.freeDiskSpaceInBytes
    XCTAssertGreaterThan(freeDiskSpace, 0)
  }
}
