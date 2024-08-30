//
//  DispatchTimeInterval+Comparable.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/28/21.
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

extension DispatchTimeInterval: Comparable {

  public static func < (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
    lhs.nonOptionalTimeInterval < rhs.nonOptionalTimeInterval
  }

  public static func > (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
    lhs.nonOptionalTimeInterval > rhs.nonOptionalTimeInterval
  }

  private var nonOptionalTimeInterval: TimeInterval {
    switch self {
    case .seconds(let value):
      return TimeInterval(value)
    case .milliseconds(let value):
      return TimeInterval(value) * 0.001
    case .microseconds(let value):
      return TimeInterval(value) * 0.000001
    case .nanoseconds(let value):
      return TimeInterval(value) * 0.000000001
    case .never:
      return TimeInterval.greatestFiniteMagnitude
    @unknown default:
      ChouTi.assertFailure("unknown DispatchTimeInterval: \(self)")
      return TimeInterval.greatestFiniteMagnitude
    }
  }
}
