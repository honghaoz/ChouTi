//
//  Clock.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/31/24.
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

/// A clock that can be used to control the flow of time.
protocol Clock {

  /// Returns the current time.
  func now() -> TimeInterval

  /// Schedules a block to be executed after a given delay.
  ///
  /// - Parameters:
  ///   - delay: The delay before the block is executed.
  ///   - queue: The queue on which the block is executed.
  ///   - block: The block to be executed.
  /// - Returns: A token that can be used to cancel the scheduled block.
  @discardableResult
  func delay(_ delay: TimeInterval, queue: DispatchQueue, block: @escaping () -> Void) -> CancellableToken
}
