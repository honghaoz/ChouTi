//
//  Waiter.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/12/21.
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

public enum Waiter {

  /// Pauses execution for a specified duration without blocking the main queue.
  ///
  /// This method must be called on the main thread. Unlike using DispatchSemaphore or DispatchGroups,
  /// this approach allows other work to be dispatched on the main queue while waiting.
  ///
  /// - Parameter timeout: The duration to wait, in seconds.
  public static func wait(timeout: TimeInterval) {
    assertOnMainThread()

    // _ = XCTWaiter.wait(for: [expectation(description: "wait")], timeout: timeout)

    // RunLoop.main is slightly faster than RunLoop.current
    RunLoop.main.run(until: Date(timeInterval: timeout, since: Date()))
  }
}

/// Pauses execution for a specified duration without blocking the main queue.
///
/// - Parameter timeout: The duration to wait, in seconds.
public func wait(timeout: TimeInterval) {
  Waiter.wait(timeout: timeout)
}

/// How wait(for: [expectation], timeout: 2) works.
/// https://stackoverflow.com/questions/59741819/how-does-wait-succeed-for-a-block-that-is-to-be-executed-on-the-next-dispatch

/// XCTWaiter.wait(for: [expectation(description: "wait")], timeout: timeout) source:
/// https://github.com/apple/swift-corelibs-xctest/blob/ab1677255f187ad6eba20f54fc4cf425ff7399d7/Sources/XCTest/Public/Asynchronous/XCTWaiter.swift#L358

/// How to use RunLoop
/// - https://rderik.com/blog/understanding-the-runloop-model-by-creating-a-basic-shell/
/// - [Apple Threading Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)
