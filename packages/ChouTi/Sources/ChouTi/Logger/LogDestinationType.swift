//
//  LogDestinationType.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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

/// A log write destination.
public protocol LogDestinationType: TextOutputStream {

  /// Write a log message to the destination.
  /// - Parameter string: The log message to write.
  func write(_ string: String)
}

// MARK: - LogDestination

// Why this type?
// Having a concrete type `LogDestination` so that you can simply use `.standardOut` in Logger initializer.

public extension LogDestinationType {

  /// Convert to a `LogDestination`.
  /// - Returns: A `LogDestination`.
  func asLogDestination() -> LogDestination {
    LogDestination(wrapped: self)
  }
}

/// A log destination type wrapper.
public struct LogDestination: LogDestinationType {

  /// The wrapped log destination.
  public let wrapped: LogDestinationType

  /// Create a log destination.
  /// - Parameter wrapped: The wrapped log destination.
  public init(wrapped: LogDestinationType) {
    self.wrapped = wrapped
  }

  @inlinable
  @inline(__always)
  public func write(_ string: String) {
    wrapped.write(string)
  }
}
