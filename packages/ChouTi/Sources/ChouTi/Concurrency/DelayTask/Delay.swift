//
//  Delay.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// A delay task type that can be cancelled, chained with another task.
public protocol DelayTaskType: AnyObject {

  var isCanceled: Bool { get }
  var isExecuted: Bool { get }

  /// Executes the task.
  ///
  /// - Executes synchronously if on the same work queue.
  /// - Executes asynchronously if on different work queue.
  func execute()

  /// Cancel task if not executed, assert if already executed or cancelled.
  func cancel()

  /// Cancel if task, regardless if task is executed or cancelled.
  func cancelIfNeeded()

  @discardableResult
  func then(delay delayedSeconds: TimeInterval, task: @escaping () -> Void) -> DelayTaskType

  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, task: @escaping () -> Void) -> DelayTaskType

  @discardableResult
  func then(delay delayedSeconds: TimeInterval, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType

  @discardableResult
  func then(delay delayedSeconds: TimeInterval, qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType

  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType

  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType
}

/// Cancelable delayed task.
private final class PrivateDelayTask: DelayTaskType {

  /// The global store to keep `PrivateDelayTask` reference.
  private static var store: [MachTimeId: PrivateDelayTask] = [:]
  private static let storeLock = UnfairLock()

  /// Unique id used in store.
  private let id = MachTimeId.id()

  /// Whether this task is canceled.
  private(set) var isCanceled: Bool = false

  /// Whether this task is executing.
  private var isExecuting: Bool = false

  /// Whether this task has been executed.
  private(set) var isExecuted: Bool = false

  /// Closure to be executed.
  private let task: () -> Void

  /// Delay in seconds.
  private let delayedSeconds: TimeInterval

  /// The leeway for the underlying timer.
  private let leeway: TimerLeeway?

  private let qos: DispatchQoS
  private let flags: DispatchWorkItemFlags

  /// The queue to run.
  private weak var queue: DispatchQueue?

  /// The underlying work item, must keep a strong reference to cancel it.
  private var workItem: DispatchWorkItem?

  /// The delay timer if used.
  private var timer: DispatchTimer?

  /// Next chained task.
  private var nextTask: PrivateDelayTask?

  /// Init a delay task.
  ///
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - leeway: The leeway for timer. Specify a value to use `DispatchTimer`.
  ///   - qos: The qos of the task.
  ///   - flags: The flags for the underlying work item.
  ///   - queue: The queue to execute the task.
  ///   - task: The task block.
  fileprivate init(delayedSeconds: TimeInterval,
                   leeway: TimerLeeway?,
                   qos: DispatchQoS,
                   flags: DispatchWorkItemFlags,
                   queue: DispatchQueue,
                   task: @escaping () -> Void)
  {
    let delayedSeconds: TimeInterval = {
      if !delayedSeconds.isFinite {
        ChouTi.assertFailure("delay seconds must be finite", metadata: [
          "delay": "\(delayedSeconds)",
        ])
        return 0
      } else {
        return delayedSeconds
      }
    }()

    self.delayedSeconds = delayedSeconds
    self.leeway = leeway

    self.qos = qos
    self.flags = flags

    self.queue = queue
    self.task = task
  }

  /// Start the task.
  fileprivate func start() {
    if isCanceled {
      return
    }

    guard let queue = self.queue else {
      ChouTi.assertFailure("queue is nil")
      return
    }

    let workItem = DispatchWorkItem(qos: qos, flags: flags, block: { [weak self] in
      guard let self else {
        // can be nil if caller cancels task and set the task to nil
        // ChouTi.assertFailure("nil self")
        return
      }

      guard self.isCanceled == false else {
        ChouTi.assertFailure("workItem should already be cancelled.")
        return
      }
      guard self.isExecuted == false else {
        // early executed
        return
      }

      self.isExecuting = true
      self.task()
      self.isExecuting = false
      self.isExecuted = true

      PrivateDelayTask.storeLock.withLock {
        ChouTi.assert(PrivateDelayTask.store[self.id] != nil)
        PrivateDelayTask.store[self.id] = nil
        // NSLog("☄️: release: \(self.id), \(Self.store.count)")
      }

      // dispatch next task if has one
      if let nextTask = self.nextTask {
        nextTask.start()
      }
    })
    self.workItem = workItem

    // store the task must happen before executing the task below, since tasks with 0 delay can execute asynchronously.
    PrivateDelayTask.storeLock.withLock {
      PrivateDelayTask.store[id] = self
      // NSLog("☄️: add: \(id), \(self), \(delayedSeconds), \(Self.store.count)")
    }

    if let leeway {
      if delayedSeconds <= 0 {
        onQueueAsync(queue: queue, execute: workItem)
      } else {
        timer = DispatchTimer.delayTimer(after: delayedSeconds, isStrict: leeway.isStrict, leeway: leeway, queue: queue, block: { [weak workItem] in workItem?.perform() })
      }
    } else {
      onQueueAsync(queue: queue, delay: delayedSeconds, execute: workItem)
    }
  }

  public func execute() {
    ChouTi.assert(isExecuted == false)
    ChouTi.assert(isCanceled == false)

    guard let queue = self.queue else {
      ChouTi.assertFailure("queue is nil")
      return
    }

    if let workItem {
      onQueueAsync(queue: queue, execute: workItem)
    } else {
      ChouTi.assertFailure("work item shouldn't be nil")
    }
  }

  public func cancel() {
    cancel(assertIfExecuted: true)
  }

  public func cancelIfNeeded() {
    if isCanceled || isExecuting || isExecuted {
      return
    }
    cancel(assertIfExecuted: false)
  }

  private func cancel(assertIfExecuted: Bool) {
    if isCanceled {
      ChouTi.assertFailure("task is already cancelled")
      return
    }

    if isExecuting {
      ChouTi.assertFailure("cancel while executing")
      return
    }

    if isExecuted {
      // already executed
      if assertIfExecuted {
        ChouTi.assertFailure("task is already executed")
      }
      return
    }

    // workItem could be nil if not started yet
    workItem?.cancel()
    isCanceled = true

    // cancel next task if has one
    if let nextTask {
      nextTask.cancel(assertIfExecuted: assertIfExecuted)
    }

    PrivateDelayTask.storeLock.withLock {
      PrivateDelayTask.store[id] = nil
      // NSLog("☄️: release: \(id), \(Self.store.count)")
    }
  }

  /// Chaining a new task on main queue.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - task: The closure to run.
  /// - Returns: A delay task.
  @inlinable
  @inline(__always)
  @discardableResult
  public func then(delay delayedSeconds: TimeInterval, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: nil, queue: .main, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: leeway, queue: .main, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public func then(delay delayedSeconds: TimeInterval, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: nil, qos: .unspecified, flags: [], queue: queue, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public func then(delay delayedSeconds: TimeInterval, qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: nil, qos: qos, flags: flags, queue: queue, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: leeway, qos: .unspecified, flags: [], queue: queue, task: task)
  }

  /// Chaining a new task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - queue: The dispatch queue to run on.
  ///   - task: The closure to run.
  /// - Returns: A delay task.
  @discardableResult
  public func then(delay delayedSeconds: TimeInterval,
                   leeway: TimerLeeway? = nil,
                   qos: DispatchQoS = .unspecified,
                   flags: DispatchWorkItemFlags = [],
                   queue: DispatchQueue,
                   task: @escaping () -> Void) -> DelayTaskType
  {
    let task = PrivateDelayTask(
      delayedSeconds: delayedSeconds,
      leeway: leeway,
      qos: qos,
      flags: flags,
      queue: queue,
      task: task
    )
    nextTask = task
    return task
  }
}

// MARK: - Public Methods

/// Execute the task closure on specified queue after delayed seconds.
///
/// Example:
/// ```
/// // exact 1 second delayed task.
/// delay(1, leeway: .zero) {
///   // ...
/// }
/// ```
///
/// - Parameters:
///   - delayedSeconds: Delay in seconds.
///   - leeway: Specify a value to use `DispatchTimer` to drive the delay.
///   - qos: DispatchQoS.
///   - flags: DispatchWorkItemFlags.
///   - queue: The queue to run the task. By default, the main queue is used.
///   - task: The task closure.
/// - Returns: A delay task token that you can cancel.
@discardableResult
public func delay(_ delayedSeconds: TimeInterval,
                  leeway: TimerLeeway? = nil,
                  qos: DispatchQoS = .unspecified,
                  flags: DispatchWorkItemFlags = [],
                  queue: DispatchQueue = .main,
                  task: @escaping () -> Void) -> DelayTaskType
{
  let task = PrivateDelayTask(
    delayedSeconds: delayedSeconds,
    leeway: leeway,
    qos: qos,
    flags: flags,
    queue: queue,
    task: task
  )
  task.start()
  return task
}

/// Async version of delay.
public func delay(_ delayedSeconds: TimeInterval,
                  leeway: TimerLeeway? = nil,
                  qos: DispatchQoS = .unspecified,
                  flags: DispatchWorkItemFlags = [],
                  queue: DispatchQueue = .main) async
{
  await withContinuation { continuation in
    delay(delayedSeconds, leeway: leeway, qos: qos, flags: flags, queue: queue, task: {
      continuation.resume()
    })
  }
}

/// Execute the task on the specified queue after delay.
/// - Parameters:
///   - duration: Delay duration.
///   - leeway: Specify a value to use `DispatchTimer` to drive the delay.
///   - qos: DispatchQoS.
///   - flags: DispatchWorkItemFlags.
///   - queue: The queue to run the task. By default, the main queue is used.
///   - task: The task closure.
/// - Returns: A delay task token that you can cancel.
@discardableResult
public func delay(_ duration: Duration,
                  leeway: TimerLeeway? = nil,
                  qos: DispatchQoS = .unspecified,
                  flags: DispatchWorkItemFlags = [],
                  queue: DispatchQueue = .main,
                  task: @escaping () -> Void) -> DelayTaskType
{
  delay(duration.seconds, leeway: leeway, qos: qos, flags: flags, queue: queue, task: task)
}

/// Async version of delay.
public func delay(_ duration: Duration,
                  leeway: TimerLeeway? = nil,
                  qos: DispatchQoS = .unspecified,
                  flags: DispatchWorkItemFlags = [],
                  queue: DispatchQueue = .main) async
{
  await withContinuation { continuation in
    delay(duration, leeway: leeway, qos: qos, flags: flags, queue: queue, task: {
      continuation.resume()
    })
  }
}
