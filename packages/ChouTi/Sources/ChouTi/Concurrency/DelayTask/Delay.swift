//
//  Delay.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

// MARK: - DelayTaskType

/// A delay task type that can be cancelled, chained with another task.
public protocol DelayTaskType: AnyObject {

  /// Indicates whether the task is canceled.
  var isCanceled: Bool { get }

  /// Indicates whether the task is executed.
  var isExecuted: Bool { get }

  /// Executes the task immediately.
  ///
  /// The task will be executed immediately if the task is not executed or cancelled.
  ///
  /// The task will be executed on the specified queue synchronously if possible. That is if `execute()` is called on the same queue as the task's queue, the task will be executed synchronously. Otherwise, the task will be executed asynchronously.
  func execute()

  /// Cancel task if task is not executed or cancelled.
  ///
  /// This method will assert if the task is executing, executed or cancelled.
  func cancel()

  /// Cancel task if needed.
  ///
  /// If the task is executing, executed or cancelled, this method will do nothing.
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

// MARK: - PrivateDelayTask

private final class PrivateDelayTask: DelayTaskType {

  /// The global store to keep strong references to `PrivateDelayTask`. So that the task can be kept alive until it's executed.
  private static var store: [MachTimeId: PrivateDelayTask] = [:]
  private static let storeLock = UnfairLock()

  /// The unique id of the task.
  private let id = MachTimeId.id()

  /// Whether this task is canceled.
  private(set) var isCanceled: Bool {
    get { isCanceledLock.withLock { _isCanceled } }
    set { isCanceledLock.withLock { _isCanceled = newValue } }
  }

  private var _isCanceled: Bool = false
  private let isCanceledLock = UnfairLock()

  /// Whether this task is executing.
  private var isExecuting: Bool {
    get { isExecutingLock.withLock { _isExecuting } }
    set { isExecutingLock.withLock { _isExecuting = newValue } }
  }

  private var _isExecuting: Bool = false
  private let isExecutingLock = UnfairLock()

  /// Whether this task has been executed.
  private(set) var isExecuted: Bool {
    get { isExecutedLock.withLock { _isExecuted } }
    set { isExecutedLock.withLock { _isExecuted = newValue } }
  }

  private var _isExecuted: Bool = false
  private let isExecutedLock = UnfairLock()

  /// The task block.
  private let task: () -> Void

  /// Delay in seconds.
  private let delayedSeconds: TimeInterval

  /// The leeway for the underlying timer.
  private let leeway: TimerLeeway?

  private let qos: DispatchQoS

  private let flags: DispatchWorkItemFlags

  /// The queue to run.
  private weak var queue: DispatchQueue?

  /// The underlying work item. Need to keep a strong reference to it to cancel it.
  private var workItem: DispatchWorkItem?

  /// The delay timer if has one.
  private var timer: DispatchTimer?

  /// The next chained delay task.
  private var nextTask: PrivateDelayTask?

  fileprivate init(delayedSeconds: TimeInterval,
                   leeway: TimerLeeway?,
                   qos: DispatchQoS,
                   flags: DispatchWorkItemFlags,
                   queue: DispatchQueue,
                   task: @escaping () -> Void)
  {
    let delayedSeconds: TimeInterval = {
      guard delayedSeconds >= 0 else {
        ChouTi.assertFailure("delay seconds must be non-negative", metadata: [
          "delay": "\(delayedSeconds)",
        ])
        return 0
      }

      guard delayedSeconds.isFinite else {
        ChouTi.assertFailure("delay seconds must be finite", metadata: [
          "delay": "\(delayedSeconds)",
        ])
        return 0
      }

      return delayedSeconds
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
        return
      }

      guard self.isCanceled == false else {
        ChouTi.assertFailure("workItem should not be cancelled when executing")
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
        ChouTi.assert(PrivateDelayTask.store[self.id] != nil, "store should have the task reference when just executed")
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
      ChouTi.assert(PrivateDelayTask.store[id] == nil, "store should not have the task reference when just started")
      PrivateDelayTask.store[id] = self
      // NSLog("☄️: add: \(id), \(self), \(delayedSeconds), \(Self.store.count)")
    }

    // schedule the task
    if delayedSeconds <= 0 {
      onQueueAsync(queue: queue, execute: workItem)
    } else {
      if let leeway {
        timer = DispatchTimer.delayTimer(after: delayedSeconds, isStrict: leeway.isStrict, leeway: leeway, queue: queue, block: { [weak workItem] in workItem.assert("workItem should not be nil when executing")?.perform() })
      } else {
        onQueueAsync(queue: queue, delay: delayedSeconds, execute: workItem)
      }
    }
  }

  func execute() {
    guard isCanceled == false else {
      ChouTi.assertFailure("task is already cancelled")
      return
    }
    guard isExecuting == false else {
      ChouTi.assertFailure("task is already executing")
      return
    }
    guard isExecuted == false else {
      ChouTi.assertFailure("task is already executed")
      return
    }

    guard let queue = self.queue else {
      ChouTi.assertFailure("queue shouldn't be nil")
      return
    }

    guard let workItem = self.workItem else {
      ChouTi.assertFailure("work item shouldn't be nil")
      return
    }

    onQueueAsync(queue: queue, execute: workItem)
  }

  func cancel() {
    cancel(assertIfExecuted: true)
  }

  func cancelIfNeeded() {
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

    isCanceled = true

    timer?.invalidate()

    // workItem could be nil if not started yet
    workItem?.cancel()
    workItem = nil

    // cancel next task if has one
    if let nextTask {
      nextTask.cancel(assertIfExecuted: assertIfExecuted)
    }

    PrivateDelayTask.storeLock.withLock {
      PrivateDelayTask.store[id] = nil
      // NSLog("☄️: release: \(id), \(Self.store.count)")
    }
  }
}

// MARK: - Then

extension PrivateDelayTask {

  /// Chaining a new task on main queue.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - task: The closure to run.
  /// - Returns: A delay task.
  @inlinable
  @inline(__always)
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: nil, queue: .main, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: leeway, queue: .main, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType {
    then(delay: delayedSeconds, leeway: nil, qos: .unspecified, flags: [], queue: queue, task: task)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType {
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
  func then(delay delayedSeconds: TimeInterval,
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
