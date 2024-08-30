//
//  Thread+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/4/21.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

public extension Thread {

  /// Check if current process is running XCTest.
  static var isRunningXCTest: Bool {
    /// https://stackoverflow.com/a/59732115/3164091

    // ⚠️ Only works with main thread.
    /*
     Xcode 14:
      threadDictionary content:
      - swift test:
     {
         NSCurrentLifeguard = "<NSLifeguard: 0x6000034f0d00>";
         NimbleEnvironment = "<Nimble.NimbleEnvironment: 0x60000194ae40>";
         "com.apple.dt.xctest.swift-error-observation.observer-count" = 1;
         "com.apple.dt.xctest.waiter-manager" = "<XCTWaiterManager: 0x600003b29d70>";
         kXCTContextStackThreadKey =     (
             "<XCTContext: 0x6000020076c0>",
             "<XCTContext: 0x600002069f80>",
             "<XCTContext: 0x6000020686c0>",
             "<XCTContext: 0x600002021100>",
             "<XCTContext: 0x600002021580>"
         );
     }

      - Xcode:
      {
          "com.apple.dt.xctest.swift-error-observation.observer-count" = 1;
          "com.apple.dt.xctest.waiter-manager" = "<XCTWaiterManager: 0x101324590>";
          kXCTContextStackThreadKey =     (
              "<XCTContext: 0x101332430>",
              "<XCTContext: 0x100e93e90>",
              "<XCTContext: 0x100e95540>",
              "<XCTContext: 0x100e572c0>",
              "<XCTContext: 0x1012ac280>"
          );
      }

     Xcode 15:
     ▿ 2 elements
       ▿ 0 : 2 elements
         ▿ key : NimbleEnvironment
         ▿ value : <Nimble.NimbleEnvironment: 0x600000688580>
       ▿ 1 : 2 elements
         - key : kXCTContextStackThreadKey
         ▿ value : 6 elements
           - 0 : <XCTContext: 0x600002114000>
           - 1 : <XCTContext: 0x6000021320d0>
           - 2 : <XCTContext: 0x60000214e7b0>
           - 3 : <XCTContext: 0x60000212c640>
           - 4 : <XCTContext: 0x6000021324e0>
           - 5 : <XCTContext: 0x600002142ee0>
      */
    _isRunningXCTest(threadDictionary: Thread.main.threadDictionary)

    // alternative:
    // let isRunningUnitTests = NSClassFromString("XCTest") != nil
  }

  static func _isRunningXCTest(threadDictionary: NSDictionary) -> Bool {
    threadDictionary.allKeys.contains { key in
      guard let key = key as? String else {
        return false
      }
      return
        key.range(of: "xctest", options: .caseInsensitive) != nil ||
        key.contains("kXCTContextStackThreadKey")
    }
  }

  /// Get a prettified call stack symbols string.
  /// - Parameter k: The number of call stack symbols to drop.
  /// - Returns: A prettified call stack symbols string.
  static func callStackSymbolsString(dropFirst k: Int = 0) -> String {
    Thread.callStackSymbols.dropFirst(k).joined(separator: "\n")
  }
}
