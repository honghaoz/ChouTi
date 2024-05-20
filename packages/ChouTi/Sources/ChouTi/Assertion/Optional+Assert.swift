//
//  Optional+Assert.swift
//
//  Created by Honghao Zhang on 8/18/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension Optional {

  @inlinable
  /// Access optional value with assertion failure if the value is `nil`.
  /// - Parameters:
  ///   - assertionMessage: The message to show when assertion fails.
  ///   - metadata: Metadata for the assertion failure.
  /// - Returns: The unwrapped value.
  func assert(_ assertionMessage: @autoclosure () -> String = "unexpected nil value",
              metadata: @autoclosure () -> OrderedDictionary<String, String> = [:],
              file: StaticString = #fileID,
              line: UInt = #line,
              function: StaticString = #function) -> Wrapped?
  {
    #if DEBUG
    guard let unwrapped = self else {
      if !Thread.current.isRunningXCTest {
        ChouTi.assertFailure(assertionMessage(), metadata: metadata(), file: file, line: line, function: function)
      }
      return self
    }
    return unwrapped
    #else
    return self
    #endif
  }
}
