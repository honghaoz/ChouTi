//
//  DispatchWorkItem+Delay.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchWorkItem {

  /// Schedule a delayed `DispatchWorkItem`.
  /// - Parameters:
  ///   - duration: The duration to delay.
  ///   - queue: The queue to execute the work item.
  ///   - qos: The quality-of-service of the work item.
  ///   - flags: The flags for the work item.
  ///   - task: The block to execute.
  /// - Returns: The work item.
  @discardableResult
  static func delay(_ duration: Duration,
                    queue: DispatchQueue = .main,
                    qos: DispatchQoS = .unspecified,
                    flags: DispatchWorkItemFlags = [],
                    task: @escaping () -> Void) -> DispatchWorkItem
  {
    delay(
      duration.seconds,
      queue: queue,
      qos: qos,
      flags: flags,
      task: task
    )
  }

  /// Schedule a delayed `DispatchWorkItem`.
  /// - Parameters:
  ///   - delay: The time interval to delay.
  ///   - queue: The queue to execute the work item.
  ///   - qos: The quality-of-service of the work item.
  ///   - flags: The flags for the work item.
  ///   - task: The block to execute.
  /// - Returns: The work item.
  @discardableResult
  static func delay(_ delay: TimeInterval,
                    queue: DispatchQueue = .main,
                    qos: DispatchQoS = .unspecified,
                    flags: DispatchWorkItemFlags = [],
                    task: @escaping () -> Void) -> DispatchWorkItem
  {
    let workItem = DispatchWorkItem(qos: qos, flags: flags, block: task)
    DispatchQueue.onQueueAsync(queue: queue, delay: delay, execute: workItem)
    return workItem
  }
}
