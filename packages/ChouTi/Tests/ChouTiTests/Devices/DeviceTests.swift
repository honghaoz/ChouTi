//
//  DeviceTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
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

  // Test free disk space
  func testFreeDiskSpaceInBytes() {
    let freeDiskSpace = Device.freeDiskSpaceInBytes
    expect(freeDiskSpace).to(beGreaterThan(0))
  }
}
