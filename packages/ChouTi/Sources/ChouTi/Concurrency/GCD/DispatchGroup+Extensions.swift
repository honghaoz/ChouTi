//
//  DispatchGroup+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/23/21.
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

public extension DispatchGroup {

  /// Schedules the submission of a block with the specified attributes to a queue when all tasks in the current group have finished executing.
  ///
  /// - Parameters:
  ///   - qos: The quality of service class for the work to be performed.
  ///   - flags: Options for how the work is performed.
  ///   - queue: The queue to which the supplied block is submitted when the group completes.
  ///   - work: The block to execute when the group is finished.
  @inlinable
  @inline(__always)
  func async(qos: DispatchQoS = .unspecified,
             flags: DispatchWorkItemFlags = [],
             queue: DispatchQueue,
             execute work: @escaping () -> Void)
  {
    notify(qos: qos, flags: flags, queue: queue, execute: work)
  }

  /// Schedules the submission of a block with the specified attributes to a queue when all tasks in the current group have finished executing.
  ///
  /// - Parameters:
  ///   - qos: The quality of service class for the work to be performed.
  ///   - flags: Options for how the work is performed.
  ///   - queue: The queue to which the supplied block is submitted when the group completes.
  ///   - timeoutInterval: The time out interval.
  ///   - timeoutBlock: The block to execute if group is not finished when timed out.
  ///   - work: The block to execute when the group is finished.
  func async(qos: DispatchQoS = .unspecified,
             flags: DispatchWorkItemFlags = [],
             queue: DispatchQueue,
             timeoutInterval: TimeInterval,
             timeout timeoutBlock: @escaping () -> Void,
             execute work: @escaping () -> Void)
  {
    guard timeoutInterval > 0 else {
      ChouTi.assertFailure("Timeout interval should be greater than 0", metadata: ["timeoutInterval": "\(timeoutInterval)"])
      async(qos: qos, flags: flags, queue: queue, execute: work)
      return
    }

    var isTimedOut: Bool = false
    let delayToken = delay(timeoutInterval, queue: queue) {
      isTimedOut = true
      timeoutBlock()
    }
    notify(qos: qos, flags: flags, queue: queue, execute: { [weak delayToken] in
      delayToken?.cancel()
      if !isTimedOut {
        work()
      }
    })
  }

  /// Execute a block once the group have finished executing.
  /// - Parameter work: The block to execute when the group is finished.
  @inlinable
  @inline(__always)
  func sync(execute work: () -> Void) {
    wait()
    work()
  }

  /// Execute a block when the group have finished executing.
  /// - Parameters:
  ///   - waitTimeout: The latest time to wait for a group to complete.
  ///   - timeoutBlock: The block to execute if group is not finished when timed out.
  ///   - work: The block to execute when the group is finished.
  func sync(waitTimeout: DispatchTime, timeout timeoutBlock: () -> Void, execute work: () -> Void) {
    let result = wait(timeout: waitTimeout)
    switch result {
    case .timedOut:
      timeoutBlock()
    case .success:
      work()
    }
  }

  /// Execute a block when the group have finished executing.
  /// - Parameters:
  ///   - waitWallTimeout: The latest time to wait for a group to complete.
  ///   - timeoutBlock: The block to execute if group is not finished when timed out.
  ///   - work: The block to execute when the group is finished.
  func sync(waitWallTimeout: DispatchWallTime, timeout timeoutBlock: () -> Void, execute work: () -> Void) {
    let result = wait(wallTimeout: waitWallTimeout)
    switch result {
    case .timedOut:
      timeoutBlock()
    case .success:
      work()
    }
  }
}
