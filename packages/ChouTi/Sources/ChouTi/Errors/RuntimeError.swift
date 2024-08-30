//
//  RuntimeError.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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
    case (error(let e1), error(let e2)):
      return String(describing: e1) == String(describing: e2)
    default:
      return false
    }
  }
}
