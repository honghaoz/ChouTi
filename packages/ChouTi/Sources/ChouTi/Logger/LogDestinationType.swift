//
//  LogDestinationType.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// A log write destination.
public protocol LogDestinationType: TextOutputStream {

  func write(_ string: String)
}

// MARK: - LogDestination

// Why this type?
// Having a concrete type `LogDestination` so that you can simply use `.standardOut` in Logger initializer.

public extension LogDestinationType {

  @inlinable
  @inline(__always)
  func asLogDestination() -> LogDestination {
    LogDestination(wrapped: self)
  }
}

public struct LogDestination: LogDestinationType {

  @usableFromInline
  let wrapped: LogDestinationType

  public init(wrapped: LogDestinationType) {
    self.wrapped = wrapped
  }

  @inlinable
  @inline(__always)
  public func write(_ string: String) {
    wrapped.write(string)
  }
}
