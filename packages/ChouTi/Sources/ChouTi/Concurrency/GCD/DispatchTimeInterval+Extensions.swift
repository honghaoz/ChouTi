//
//  DispatchTimeInterval+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/3/21.
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

// MARK: - TimeInterval to DispatchTimeInterval

public extension TimeInterval {

  /// Convert `TimeInterval` to `DispatchTimeInterval`.
  ///
  /// - Parameter assertIfNotExact: If should assert the conversion is exact. `DispatchTimeInterval` only supports nanoseconds precision.
  ///   For interval like `0.5859688448927677`, it can't be represented in `DispatchTimeInterval` exactly.
  /// - Returns: A converted `DispatchTimeInterval`.
  func dispatchTimeInterval(assertIfNotExact: Bool = true) -> DispatchTimeInterval {
    ChouTi.Duration.seconds(self).dispatchTimeInterval(assertIfNotExact: assertIfNotExact)
  }
}

// MARK: - DispatchTimeInterval to TimeInterval

public extension TimeInterval {

  init(dispatchTimeInterval: DispatchTimeInterval) {
    switch dispatchTimeInterval {
    case .nanoseconds(let value):
      self = TimeInterval(value) / 1e9
    case .microseconds(let value):
      self = TimeInterval(value) / 1e6
    case .milliseconds(let value):
      self = TimeInterval(value) / 1e3
    case .seconds(let value):
      self = TimeInterval(value)
    case .never:
      self = .greatestFiniteMagnitude
    @unknown default:
      ChouTi.assertFailure("unknown DispatchTimeInterval: \(dispatchTimeInterval)")
      self = .greatestFiniteMagnitude
    }
  }
}

public extension DispatchTimeInterval {

  /// `DispatchTimeInterval` -> `TimeInterval`.
  var timeInterval: TimeInterval {
    TimeInterval(dispatchTimeInterval: self)
  }
}
