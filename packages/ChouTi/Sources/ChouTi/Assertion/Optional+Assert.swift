//
//  Optional+Assert.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/18/21.
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

public extension Optional {

  /// Access optional value with assertion failure if the value is `nil`.
  /// - Parameters:
  ///   - assertionMessage: The message to show when assertion fails.
  ///   - metadata: Metadata for the assertion failure.
  /// - Returns: The unwrapped value.
  @inlinable
  func assert(_ assertionMessage: @autoclosure () -> String = "Unexpected nil value",
              metadata: @autoclosure () -> OrderedDictionary<String, String> = [:],
              file: StaticString = #fileID,
              line: UInt = #line,
              function: StaticString = #function) -> Wrapped?
  {
    #if DEBUG
    guard let unwrapped = self else {
      ChouTi.assertFailure(assertionMessage(), metadata: metadata(), file: file, line: line, function: function)
      return self
    }
    return unwrapped
    #else
    return self
    #endif
  }
}
