//
//  Device.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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
import IOKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public enum Device {

  public enum DeviceType {
    case iPhone
    case iPad
    case mac
    case tv
    // case vision
  }

  public static let deviceType: DeviceType = {
    #if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .iPad
    } else {
      return .iPhone
    }
    #elseif os(macOS)
    return .mac
    #elseif os(tvOS)
    return .tv
    #elseif os(visionOS)
    return .iPhone // TODO: support vision
    #else
    ChouTi.assertFailure("Unsupported device type.")
    return .iPhone
    #endif
  }()

  // MARK: - macOS

  #if os(macOS)

  /// Version object, for example: 10.15.5.
  @inlinable
  @inline(__always)
  public static var version: OperatingSystemVersion {
    ProcessInfo.processInfo.operatingSystemVersion
  }

  /// 10.15.5
  public static var versionString: String {
    "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }

  /// Foo's Macbook Pro
  @inlinable
  @inline(__always)
  public static var deviceName: String? {
    Host.current().localizedName
  }

  public static func modelIdentifier() -> String? {
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    defer {
      IOObjectRelease(service)
    }

    guard let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data else {
      return nil
    }

    return String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)

    /// https://stackoverflow.com/questions/20070333/obtain-model-identifier-string-on-os-x
    /// https://www.reddit.com/r/swift/comments/gwf9fa/how_do_i_find_the_model_of_the_mac_in_swift/
    /// https://mactracker.ca
    /// https://support.apple.com/en-us/HT201862
    /// https://support.apple.com/en-sa/HT201300
    /// https://stackoverflow.com/questions/32370037/is-there-a-way-of-getting-a-macs-icon-given-its-model-number/32381289#32381289
  }

  /// Check if the MacBook has a notch.
  public static func hasNotch() -> Bool {
    guard let modelIdentifier = modelIdentifier() else {
      guard let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight else {
        return false
      }
      return menuBarHeight > 24
    }

    let notchModels = Set([
      /// MacBook Pro: https://support.apple.com/en-us/108052
      "MacBookPro18,1", "MacBookPro18,2", // MacBook Pro (16-inch, 2021), M1
      "MacBookPro18,3", "MacBookPro18,4", // MacBook Pro (14-inch, 2021), M1
      "Mac14,6", "Mac14,10", // MacBook Pro (16-inch, 2023), M2
      "Mac14,5", "Mac14,9", // MacBook Pro (14-inch, 2023), M2
      "Mac15,7", "Mac15,9", "Mac15,11", // MacBook Pro (16-inch, Nov 2023), M3
      "Mac15,6", "Mac15,8", "Mac15,10", "Mac15,3", // MacBook Pro (14-inch, Nov 2023), M3
      /// MacBook Air: https://support.apple.com/en-us/102869
      "Mac14,2", // MacBook Air (M2, 2022)
      "Mac14,15", // MacBook Air (15-inch, M2, 2023)
      "Mac15,12", // MacBook Air (13-inch, M3, 2024)
      "Mac15,13", // MacBook Air (15-inch, M3, 2024)
    ])

    #if DEBUG
    // make Date for 2024-09-10
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2024
    components.month = 9
    components.day = 10
    if let lastUpdatedAt = calendar.date(from: components).assert("failed to create date") {
      let now = Date()
      if now.hasBeen(.months(6), since: lastUpdatedAt) {
        ChouTi.assertFailure("Please update the Mac notch models.")
      }
    }
    #endif

    return notchModels.contains(modelIdentifier)
  }

  #else

  // MARK: - iOS

  // TODO: add iOS
  #endif

  // MARK: - All

  /// Get the free disk space in bytes.
  public static var freeDiskSpaceInBytes: Int64 {
    let getAvailableSpace = {
      do {
        let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
        let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
        return freeSpace.assert() ?? 0
      } catch {
        ChouTi.assertFailure("failed to get free disk space", metadata: ["error": "\(error)"])
        return 0
      }
    }
    #if os(tvOS)
    return getAvailableSpace()
    #else
    do {
      let freeSpace = try URL(fileURLWithPath: NSHomeDirectory() as String)
        .resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey])
        .volumeAvailableCapacityForImportantUsage
      return freeSpace.assert() ?? 0
    } catch {
      return getAvailableSpace()
    }
    #endif
  }

  /// Get a unique device UUID.
  /// - Returns: A uuid string.
  public static func uuid() -> String? {
    #if os(macOS)
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    defer {
      IOObjectRelease(service)
    }

    if service == 0 {
      ChouTi.assertFailure("service doesn't exist")
      return nil
    }

    // get the platform UUID property from the service
    let cfUUID = IORegistryEntryCreateCFProperty(service, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0)

    guard let uuid = cfUUID?.takeUnretainedValue() as? String else {
      ChouTi.assertFailure("failed to convert to string")
      return nil
    }

    return uuid

    /// https://forums.developer.apple.com/forums/thread/117978
    /// https://gist.github.com/ericdke/ed2d8bd3d127c25bcc6b
    #elseif canImport(UIKit)
    return UIDevice.current.identifierForVendor?.uuidString
    #else
    ChouTi.assertFailure("Unsupported platform")
    return nil
    #endif
  }
}

/// References:
/// - https://github.com/AndreaMiotto/ActionOver/blob/master/Sources/ActionOver/View%2BIfDeviceType.swift#L16-L26
