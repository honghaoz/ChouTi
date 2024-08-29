//
//  System.swift
//
//  Created by Honghao Zhang on 4/14/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public enum System {

  #if os(macOS)
  /// The current system is >= Sonoma.
  public static var macOS_sonoma: Bool {
    if #available(macOS 14, *) {
      return true
    } else {
      return false
    }
  }

  /// The current system is >= Ventura.
  public static var macOS_ventura: Bool {
    if #available(macOS 13, *) {
      return true
    } else {
      return false
    }
  }

  /// The current system is >= Monterey.
  public static var macOS_monterey: Bool {
    // ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 12, minorVersion: 0, patchVersion: 0))
    if #available(macOS 12, *) {
      return true
    } else {
      return false
    }
  }

  /// The current system is >= Big Sur.
  public static var macOS_bigSur: Bool {
    if #available(macOS 10.16, *) {
      return true
    } else {
      return false
    }
  }
  #endif

  #if os(iOS)
  /// The current system is >= iOS 17
  public static var iOS_17: Bool {
    if #available(iOS 17, *) {
      return true
    } else {
      return false
    }
  }

  /// The current system is >= iOS 16
  public static var iOS_16: Bool {
    if #available(iOS 16, *) {
      return true
    } else {
      return false
    }
  }

  /// The current system is >= iOS 15
  public static var iOS_15: Bool {
    if ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 15, minorVersion: 0, patchVersion: 0)) {
      return true
    } else {
      return false
    }

    // if #available(iOS 15, *) {
    //   return true
    // } else {
    //   return false
    // }
  }

  /// The current system is >= iOS 14
  public static var iOS_14: Bool {
    if #available(iOS 14, *) {
      return true
    } else {
      return false
    }
  }

  /// The current system is >= iOS 13
  public static var iOS_13: Bool {
    if #available(iOS 13, *) {
      return true
    } else {
      return false
    }
  }
  #endif
}

/*
 References:
 - https://www.avanderlee.com/swift/available-deprecated-renamed/
 */

/**
 From WWDC 2022 uiframewroks-lounge:
 Pro-tip: You can use [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: to help pick whether to
 use “settings” or “preferences” based on OS version.
 */
