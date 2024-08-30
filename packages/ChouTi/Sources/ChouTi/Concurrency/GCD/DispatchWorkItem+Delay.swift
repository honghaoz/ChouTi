//
//  DispatchWorkItem+Delay.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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
