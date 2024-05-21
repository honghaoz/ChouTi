//
//  DispatchWorkItem+Delay.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchWorkItem {

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

  /**
   Example:

   ```
   let task = DispatchWorkItem.delay(2) {
     // do your work
   }
   task.cancel()
   ```
   */
  /// Create a delayed DispatchWorkItem
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

@discardableResult
public func delayWorkItem(_ duration: Duration,
                          queue: DispatchQueue = .main,
                          qos: DispatchQoS = .unspecified,
                          flags: DispatchWorkItemFlags = [],
                          task: @escaping () -> Void) -> DispatchWorkItem
{
  DispatchWorkItem.delay(
    duration.seconds,
    queue: queue,
    qos: qos,
    flags: flags,
    task: task
  )
}

/**
 Example:

 ```
 let task = delay(2) {
 // do your work
 }
 task.cancel()
 ```
 */
/// Create a delayed DispatchWorkItem
@discardableResult
@inlinable
@inline(__always)
public func delayWorkItem(_ delay: TimeInterval,
                          queue: DispatchQueue = .main,
                          qos: DispatchQoS = .unspecified,
                          flags: DispatchWorkItemFlags = [],
                          task: @escaping () -> Void) -> DispatchWorkItem
{
  DispatchWorkItem.delay(
    delay,
    queue: queue,
    qos: qos,
    flags: flags,
    task: task
  )
}
