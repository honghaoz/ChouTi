//
//  DispatchGroup+Extensions.swift
//
//  Created by Honghao Zhang on 10/23/21.
//  Copyright © 2024 ChouTi. All rights reserved.
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
      ChouTi.assertFailure("invalid timeout interval: \(timeoutInterval)")
      async(qos: qos, flags: flags, queue: queue, execute: work)
      return
    }
    let delayToken = delay(timeoutInterval, queue: queue) {
      timeoutBlock()
    }
    notify(qos: qos, flags: flags, queue: queue, execute: { [weak delayToken] in
      delayToken?.cancel()
      work()
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
