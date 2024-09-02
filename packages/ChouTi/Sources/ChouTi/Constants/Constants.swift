//
//  Constants.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/9/21.
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
public var isDebuggingUsingXcode: Bool { isatty(STDERR_FILENO) == 1 }

/// - `isatty(STDERR_FILENO)` is `1` if app launches with Xcode LLDB.
/// - `isatty(STDERR_FILENO)` is `0` if app launches directly
/// From: https://stackoverflow.com/a/44434274/3164091
#endif

public var isRunningAsRoot: Bool { getuid() == 0 }
