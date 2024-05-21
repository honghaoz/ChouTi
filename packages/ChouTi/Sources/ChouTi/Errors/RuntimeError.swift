//
//  RuntimeError.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// A runtime error.
///
/// This is convenient error type that can be used to wrap any error or reason string.
/// It's useful to avoid defining custom error types for simple errors.
public enum RuntimeError: Swift.Error {

  case empty
  case reason(String)
  case error(Swift.Error)

  public var description: String {
    switch self {
    case .empty:
      return "<empty>"
    case .reason(let reason):
      return reason
    case .error(let error):
      return String(describing: error)
    }
  }
}

// MARK: - Equatable

extension RuntimeError: Equatable {

  public static func == (lhs: RuntimeError, rhs: RuntimeError) -> Bool {
    switch (lhs, rhs) {
    case (empty, empty):
      return true
    case (reason(let r1), reason(let r2)):
      return r1 == r2
    default:
      return false
    }
  }
}
