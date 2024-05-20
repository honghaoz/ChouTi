//
//  Constants.swift
//
//  Created by Honghao Zhang on 1/9/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

#if DEBUG
public let isDebug = true
#else
public let isDebug = false
#endif

#if os(macOS)
public let isMac = true
#else
public let isMac = false
#endif

#if os(iOS)
public let isIOS = true
#else
public let isIOS = false
#endif

#if DEBUG
/// A flag indicates if the app is being debug with Xcode.
/// `isatty(STDERR_FILENO)` is `1` if app launches with Xcode LLDB.
/// `isatty(STDERR_FILENO)` is `0` if app launches directly
/// From: https://stackoverflow.com/a/44434274/3164091
public var isDebuggingUsingXcode: Bool { isatty(STDERR_FILENO) == 1 }
#endif

public var isRunningAsRoot: Bool { getuid() == 0 }
