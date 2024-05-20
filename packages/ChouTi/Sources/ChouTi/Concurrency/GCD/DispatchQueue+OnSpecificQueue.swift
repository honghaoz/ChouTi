//
//  DispatchQueue+OnSpecificQueue.swift
//
//  Created by Honghao Zhang on 1/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchQueue {

  private static let queueNameKey = DispatchSpecificKey<String>()

  /// Make an identifiable queue.
  ///
  /// The returned queue is compatible with APIs like:
  /// - `DispatchQueue.isOnQueue(_:)`
  /// - `DispatchQueue.onQueueAsync(queue:delay:execute:)`
  /// - `DispatchQueue.onQueueSync(queue:execute:)`
  /// - `queue.asyncIfNeeded(delay:execute:)`
  /// - `queue.syncIfNeeded(execute:)`
  ///
  /// - Parameters:
  ///   - label: The label of the queue.
  ///   - qos: The quality-of-service level to associate with the queue.
  ///   - attributes: The attributes to associate with the queue.
  ///   - autoreleaseFrequency: The frequency with which to autorelease objects created by the blocks that the queue schedules.
  ///   - target: The target queue on which to execute blocks.
  /// - Returns: A new queue.
  static func make(
    label: String,
    qos: DispatchQoS = .unspecified,
    attributes: DispatchQueue.Attributes = [],
    autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit,
    target: DispatchQueue? = nil
  ) -> DispatchQueue {
    /// https://swiftrocks.com/discovering-which-dispatchqueue-a-method-is-running-on

    /**
     what is DispatchQueue.AutoreleaseFrequency?
     https://stackoverflow.com/questions/38884418/autoreleasefrequency-on-dispatchqueue-in-swift-3

     should I use `DispatchQueue.AutoreleaseFrequency.workItem`?
     https://stackoverflow.com/questions/59019950/what-is-autorelease-frequency-and-target-while-creating-dispatch-queue

     seems like not needed in Swift.
     http://dduraz.com/2016/10/26/gcd/

     seems like `.workItem` is better?
     discussion: https://github.com/ReactiveCocoa/ReactiveSwift/issues/288
     */

    /**
     Set .global() for target queue.
     https://forums.swift.org/t/what-is-the-default-target-queue-for-a-serial-queue/18094/19
     https://mjtsai.com/blog/2021/03/16/underused-and-overused-gcd-patterns/
     */
    let queue = DispatchQueue(
      label: label,
      qos: qos,
      attributes: attributes,
      autoreleaseFrequency: autoreleaseFrequency,
      target: target ?? .global() // use non-overcommit global queue
    )
    queue.setSpecific(key: queueNameKey, value: label)
    return queue
  }

  /// Make an identifiable main queue.
  ///
  /// The returned queue is compatible with APIs like:
  /// - `DispatchQueue.isOnQueue(_:)`
  /// - `DispatchQueue.onQueueAsync(queue:delay:execute:)`
  /// - `DispatchQueue.onQueueSync(queue:execute:)`
  /// - `queue.asyncIfNeeded(delay:execute:)`
  /// - `queue.syncIfNeeded(execute:)`
  ///
  /// - Returns: The main queue.
  static func makeMain() -> DispatchQueue {
    let queue = DispatchQueue.main
    queue.setSpecific(key: queueNameKey, value: queue.label)
    return queue
  }

  // Global queues are not recommended to use. Use serial queues instead.
  // Code commented out for future reference.
  //
  //  /// Make a global background queue with queue name set.
  //  static func makeGlobal(qos: DispatchQoS.QoSClass = .default) -> DispatchQueue {
  //    let queue = DispatchQueue.global(qos: qos)
  //    queue.setSpecific(key: queueNameKey, value: queue.label)
  //    return queue
  //  }
  //
  //  /// Make a global background queue with queue name set.
  //  @inlinable
  //  static func makeBackground(qos: DispatchQoS.QoSClass = .default) -> DispatchQueue {
  //    makeGlobal(qos: qos)
  //  }

  /// Check if current queue is on the specific queue.
  ///
  /// The queue must be made by:
  /// - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
  /// - `DispatchQueue.makeMain()`
  /// - `DispatchQueue.shared(qos:)`
  /// - `DispatchQueue.makeSerialQueue(label:qos:)`
  ///
  /// - Parameters:
  ///   - queue: The queue to check.
  /// - Returns: `true` if current queue is on the specific queue.
  static func isOnQueue(_ queue: DispatchQueue,
                        file: StaticString = #fileID,
                        line: UInt = #line,
                        column: UInt = #column) -> Bool
  {
    _isOnQueue(queue, file: file, line: line, column: column)
  }

  private static func _isOnQueue(_ queue: DispatchQueue,
                                 file: StaticString = #fileID,
                                 line: UInt = #line,
                                 column: UInt = #column) -> Bool
  {
    setCommonQueuesLabelKey()

    let currentQueueLabel = DispatchQueue.getSpecific(key: queueNameKey)
    if currentQueueLabel == nil {
      #if DEBUG
      if DispatchQueue.currentQueueLabel.hasSuffix(Constants.cooperativeQueueSuffix) ||
        DispatchQueue.currentQueueLabel == Constants.urlSessionDelegateQueueLabel
      {
        // ignore common known queues
        return false
      } else {
        ChouTi.assertFailure("Expect a queue label for queue: \(DispatchQueue.currentQueueLabel), use static make(...) method to create a queue.", file: file, line: line, column: column)
      }
      #endif
    }
    return currentQueueLabel == queue.label
  }

  /// Update common queues label so that `static isOnQueue(_:)` can work seamlessly.
  private static func setCommonQueuesLabelKey() {
    DispatchQueue.once {
      [
        DispatchQueue.main,
        DispatchQueue.global(qos: .userInteractive),
        DispatchQueue.global(qos: .userInitiated),
        DispatchQueue.global(qos: .utility),
        DispatchQueue.global(qos: .background),
        DispatchQueue.global(qos: .default),
      ].forEach {
        $0.setSpecific(key: queueNameKey, value: $0.label)
      }
    }
  }

  #if DEBUG
  /// Check if current queue is on the Swift Concurrency (`async`/`await``) cooperative queue.
  static func isOnCooperativeQueue() -> Bool {
    DispatchQueue.currentQueueLabel.hasSuffix(Constants.cooperativeQueueSuffix)
  }
  #endif

  // MARK: - Constants

  private enum Constants {

    // com.apple.root.default-qos.cooperative
    // com.apple.root.user-initiated-qos.cooperative
    static let cooperativeQueueSuffix = ".cooperative"

    static let urlSessionDelegateQueueLabel = "com.apple.NSURLSession-delegate"
  }
}

public extension DispatchQueue {

  /// Dispatch the block to a specific queue asynchronously if not already on the queue.
  ///
  /// - If current queue is already on the queue and no delay, the block will execute immediately.
  /// - The queue must be made by:
  ///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
  ///   - `DispatchQueue.makeMain()`
  ///   - `DispatchQueue.shared(qos:)`
  ///   - `DispatchQueue.makeSerialQueue(label:qos:)`
  ///
  /// - Parameters:
  ///   - queue: The queue to dispatch the block.
  ///   - delay: The delay time before executing the block.
  ///   - qos: The quality-of-service class to associate with the block.
  ///   - flags: The flags to associate with the block.
  ///   - work: The block to execute.
  static func onQueueAsync(queue: DispatchQueue,
                           delay: TimeInterval? = nil,
                           qos: DispatchQoS = .unspecified,
                           flags: DispatchWorkItemFlags = [],
                           execute work: @escaping () -> Void,
                           file: StaticString = #fileID,
                           line: UInt = #line,
                           column: UInt = #column)
  {
    if let delay, delay > 0 {
      queue.asyncAfter(deadline: .now() + delay, qos: qos, flags: flags, execute: work)
    } else {
      if DispatchQueue.isOnQueue(queue, file: file, line: line, column: column) {
        work()
      } else {
        queue.async(qos: qos, flags: flags, execute: work)
      }
    }
  }

  /// Dispatch the work item to a specific queue asynchronously if not already on the queue.
  ///
  /// - If current queue is already on the queue and no delay, the work item will execute immediately.
  /// - The queue must be made by:
  ///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
  ///   - `DispatchQueue.makeMain()`
  ///   - `DispatchQueue.shared(qos:)`
  ///   - `DispatchQueue.makeSerialQueue(label:qos:)`
  ///
  /// - Parameters:
  ///   - queue: The queue to dispatch the work item.
  ///   - delay: The delay time before executing the work item.
  ///   - workItem: The work item to execute.
  static func onQueueAsync(queue: DispatchQueue,
                           delay: TimeInterval? = nil,
                           execute workItem: DispatchWorkItem,
                           file: StaticString = #fileID,
                           line: UInt = #line,
                           column: UInt = #column)
  {
    if let delay, delay > 0 {
      queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    } else {
      if DispatchQueue.isOnQueue(queue, file: file, line: line, column: column) {
        workItem.perform()
      } else {
        queue.async(execute: workItem)
      }
    }
  }

  /// Dispatch the block to a specific queue directly if already on the queue.
  ///
  /// - The queue must be made by:
  ///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
  ///   - `DispatchQueue.makeMain()`
  ///   - `DispatchQueue.shared(qos:)`
  ///   - `DispatchQueue.makeSerialQueue(label:qos:)`
  ///
  /// - Parameters:
  ///   - queue: The queue to dispatch the block.
  ///   - work: The block to execute.
  /// - Returns: The result of the block.
  static func onQueueSync<T>(queue: DispatchQueue,
                             execute work: () throws -> T,
                             file: StaticString = #fileID,
                             line: UInt = #line,
                             column: UInt = #column) rethrows -> T
  {
    if DispatchQueue.isOnQueue(queue, file: file, line: line, column: column) {
      return try work()
    } else {
      return try queue.sync(execute: work)
    }
  }

  /// Dispatch the block to a specific queue asynchronously if not already on the queue.
  ///
  /// - If current queue is already on the queue and no delay, the block will execute immediately.
  /// - The queue must be made by:
  ///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
  ///   - `DispatchQueue.makeMain()`
  ///   - `DispatchQueue.shared(qos:)`
  ///   - `DispatchQueue.makeSerialQueue(label:qos:)`
  ///
  /// - Parameters:
  ///   - delay: The delay time before executing the block.
  ///   - qos: The quality-of-service class to associate with the block.
  ///   - flags: The flags to associate with the block.
  ///   - work: The block to execute.
  @inlinable
  @inline(__always)
  func asyncIfNeeded(delay: TimeInterval? = nil,
                     qos: DispatchQoS = .unspecified,
                     flags: DispatchWorkItemFlags = [],
                     execute work: @escaping () -> Void,
                     file: StaticString = #fileID,
                     line: UInt = #line,
                     column: UInt = #column)
  {
    DispatchQueue.onQueueAsync(
      queue: self,
      delay: delay,
      qos: qos,
      flags: flags,
      execute: work,
      file: file,
      line: line,
      column: column
    )
  }

  /// Dispatch the block to a specific queue directly if already on the queue.
  ///
  /// - The queue must be made by:
  ///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
  ///   - `DispatchQueue.makeMain()`
  ///   - `DispatchQueue.shared(qos:)`
  ///   - `DispatchQueue.makeSerialQueue(label:qos:)`
  ///
  /// - Parameters:
  ///   - work: The block to execute.
  /// - Returns: The result of the block.
  @inlinable
  @inline(__always)
  func syncIfNeeded<T>(execute work: () throws -> T,
                       file: StaticString = #fileID,
                       line: UInt = #line,
                       column: UInt = #column) rethrows -> T
  {
    try DispatchQueue.onQueueSync(
      queue: self,
      execute: work,
      file: file,
      line: line,
      column: column
    )
  }
}

// MARK: - Global Methods

/// Dispatch the block to a specific queue asynchronously if not already on the queue.
///
/// - If current queue is already on the queue and no delay, the block will execute immediately.
/// - The queue must be made by:
///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
///   - `DispatchQueue.makeMain()`
///   - `DispatchQueue.shared(qos:)`
///   - `DispatchQueue.makeSerialQueue(label:qos:)`
///
/// - Parameters:
///   - queue: The queue to dispatch the block.
///   - delay: The delay time before executing the block.
///   - qos: The quality-of-service class to associate with the block.
///   - flags: The flags to associate with the block.
///   - block: The block to execute.
@inlinable
@inline(__always)
public func onQueueAsync(queue: DispatchQueue,
                         delay: TimeInterval? = nil,
                         qos: DispatchQoS = .unspecified,
                         flags: DispatchWorkItemFlags = [],
                         execute block: @escaping () -> Void,
                         file: StaticString = #fileID,
                         line: UInt = #line,
                         column: UInt = #column)
{
  DispatchQueue.onQueueAsync(
    queue: queue,
    delay: delay,
    qos: qos,
    flags: flags,
    execute: block,
    file: file,
    line: line,
    column: column
  )
}

/// Dispatch the work item to a specific queue asynchronously if not already on the queue.
///
/// - If current queue is already on the queue and no delay, the work item will execute immediately.
/// - The queue must be made by:
///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
///   - `DispatchQueue.makeMain()`
///   - `DispatchQueue.shared(qos:)`
///   - `DispatchQueue.makeSerialQueue(label:qos:)`
///
/// - Parameters:
///   - queue: The queue to dispatch the work item.
///   - delay: The delay time before executing the work item.
///   - workItem: The work item to execute.
@inlinable
@inline(__always)
public func onQueueAsync(queue: DispatchQueue,
                         delay: TimeInterval? = nil,
                         execute workItem: DispatchWorkItem,
                         file: StaticString = #fileID,
                         line: UInt = #line,
                         column: UInt = #column)
{
  DispatchQueue.onQueueAsync(
    queue: queue,
    delay: delay,
    execute: workItem,
    file: file,
    line: line,
    column: column
  )
}

/// Dispatch the block to a specific queue directly if already on the queue.
///
/// - The queue must be made by:
///   - `DispatchQueue.make(label:qos:attributes:autoreleaseFrequency:target:)`
///   - `DispatchQueue.makeMain()`
///   - `DispatchQueue.shared(qos:)`
///   - `DispatchQueue.makeSerialQueue(label:qos:)`
///
/// - Parameters:
///   - queue: The queue to dispatch the block.
///   - block: The block to execute.
/// - Returns: The result of the block.
@inlinable
@inline(__always)
public func onQueueSync<T>(queue: DispatchQueue,
                           execute block: () throws -> T,
                           file: StaticString = #fileID,
                           line: UInt = #line,
                           column: UInt = #column) rethrows -> T
{
  try DispatchQueue.onQueueSync(
    queue: queue,
    execute: block,
    file: file,
    line: line,
    column: column
  )
}

/**
 Reading:
 - Pro Multithreading and Memory Management for iOS and OS X
   https://dokumen.tips/documents/pro-multithreading-and-memory-management-for-ios-and-os-x-with-arc-grand.html?page=3
   Explains advanced concepts behind the GCD.
 - libdispatch efficiency tips
   https://gist.github.com/tclementdev/6af616354912b0347cdf6db159c37057
 */
