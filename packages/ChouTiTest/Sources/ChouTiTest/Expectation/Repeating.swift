//
//  Repeating.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/5/20.
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

/// Repeats a block of code at a specified interval on a specified queue.
/// - Parameters:
///   - interval: The interval at which to repeat the block.
///   - timeout: The maximum time to repeat the block.
///   - queue: The queue on which to repeat the block.
///   - block: The block to repeat.
/// - Returns: A token that can be used to stop the repeating task.
func repeating(interval: TimeInterval,
               timeout: TimeInterval = .greatestFiniteMagnitude,
               queue: DispatchQueue = .main,
               block: @escaping (Int) -> Bool)
{
  precondition(interval > 0, "interval must be greater than 0.")
  precondition(timeout > interval, "timeout must be greater than interval.")

  var loopCount = 0

  func invoke() {
    if Double(loopCount) * interval > timeout {
      return
    }
    if block(loopCount) {
      return
    }

    loopCount += 1
    queue.asyncAfter(deadline: .now() + interval) {
      invoke()
    }
  }

  queue.async {
    invoke()
  }
}
