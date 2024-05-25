//
//  Repeating.swift
//
//  Created by Honghao Zhang on 3/5/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// A token for a repeating task.
protocol RepeatingTokenType: AnyObject {

  /// Whether the repeating task is stopped.
  var isStopped: Bool { get }

  /// Stops the repeating task.
  func stop()
}

/// A `RepeatingTokenType` implementation.
private class RepeatingToken: RepeatingTokenType {

  fileprivate var isStopped: Bool = false

  fileprivate func stop() {
    assert(!isStopped, "Repeating task is already stopped.")
    isStopped = true
  }
}

/// Repeats a block of code at a specified interval on a specified queue.
/// - Parameters:
///   - interval: The interval at which to repeat the block.
///   - timeout: The maximum time to repeat the block.
///   - queue: The queue on which to repeat the block.
///   - block: The block to repeat.
/// - Returns: A token that can be used to stop the repeating task.
@discardableResult
func repeating(interval: TimeInterval,
               timeout: TimeInterval = .greatestFiniteMagnitude,
               queue: DispatchQueue = .main,
               block: @escaping (Int) -> Bool) -> RepeatingTokenType
{
  precondition(interval > 0, "interval must be > 0.")
  precondition(timeout >= 0, "Timeout must be >= 0, not \(timeout)")

  let token = RepeatingToken()
  var loopCount = 0

  func invoke() {
    guard !token.isStopped else {
      return
    }
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

  return token
}
