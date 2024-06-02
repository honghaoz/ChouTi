//
//  DispatchWorkItem+Extensions.swift
//
//  Created by Honghao Zhang on 7/23/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchWorkItem {

  /// Dispatch `self` to a dispatch queue for asynchronous execution.
  ///
  /// Example:
  /// ```swift
  /// let task = DispatchWorkItem {
  ///   ...
  /// }
  /// .asyncDispatch(to: backgroundQueue, delay: 0.1)
  ///
  /// task.cancel()
  /// ```
  ///
  /// - Parameters:
  ///   - queue: The dispatch queue to dispatch.
  ///   - delay: The delay in seconds.
  /// - Returns: `self`.
  @discardableResult
  func asyncDispatch(to queue: DispatchQueue,
                     delay: TimeInterval,
                     file: StaticString = #fileID,
                     line: UInt = #line,
                     column: UInt = #column) -> DispatchWorkItem
  {
    onQueueAsync(
      queue: queue,
      delay: delay,
      execute: self,
      file: file,
      line: line,
      column: column
    )
    return self
  }
}
