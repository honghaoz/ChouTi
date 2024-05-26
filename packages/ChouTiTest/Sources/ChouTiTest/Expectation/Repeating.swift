//
//  Repeating.swift
//
//  Created by Honghao Zhang on 3/5/20.
//  Copyright © 2024 ChouTi. All rights reserved.
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
