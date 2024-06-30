//
//  DelayTask.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

// MARK: - DelayTaskType

/// A delay task type that can be canceled and chained.
public protocol DelayTaskType: AnyObject {

  /// Indicates whether the task is canceled.
  var isCanceled: Bool { get }

  /// Indicates whether the task is executed.
  var isExecuted: Bool { get }

  /// Executes the task immediately if the task is not executed or canceled.
  ///
  /// If this method is called on the same queue as the task's queue, the task will be executed synchronously. Otherwise, the task will be executed asynchronously.
  func execute()

  /// Cancel the task.
  func cancel()

  /// Chain a new delay task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - task: The closure to run. The closure will be executed on the main queue.
  /// - Returns: The chained delay task.
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, task: @escaping () -> Void) -> DelayTaskType

  /// Chain a new delay task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - leeway: The leeway for for the delay.
  ///   - task: The closure to run. The closure will be executed on the main queue.
  /// - Returns: The chained delay task.
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, task: @escaping () -> Void) -> DelayTaskType

  /// Chain a new delay task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - queue: The dispatch queue to run on.
  ///   - task: The closure to run.
  /// - Returns: The chained delay task.
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType

  /// Chain a new delay task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - qos: The quality of service of the task.
  ///   - flags: The flags of the underlying work item.
  ///   - queue: The dispatch queue to run on.
  ///   - task: The closure to run.
  /// - Returns: The chained delay task.
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, qos: DispatchQoS, flags: DispatchWorkItemFlags, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType

  /// Chain a new delay task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - leeway: The leeway for the delay.
  ///   - queue: The dispatch queue to run on.
  ///   - task: The closure to run.
  /// - Returns: The chained delay task.
  @discardableResult
  func then(delay delayedSeconds: TimeInterval, leeway: TimerLeeway?, queue: DispatchQueue, task: @escaping () -> Void) -> DelayTaskType

  /// Chain a new delay task.
  /// - Parameters:
  ///   - delayedSeconds: The delayed seconds.
  ///   - leeway: The leeway for the delay
  ///   - qos: The quality of service of the task.
  ///   - flags: The flags of the underlying work item.
  ///   - queue: The dispatch queue to run on.
  ///   - task: The closure to run.
  /// - Returns: The chained delay task.
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

  private let taskLock = UnfairLock()

  /// Whether this task is canceled.
  var isCanceled: Bool { taskLock.withLock { _isCanceled } }
  private var _isCanceled: Bool = false

  /// Whether this task is executing.
  private var _isExecuting: Bool = false

  /// Whether this task has been executed.
  var isExecuted: Bool { taskLock.withLock { _isExecuted } }
  private var _isExecuted: Bool = false

  /// The task block.
  private let task: () -> Void

  /// Delay in seconds.
  private let delayedSeconds: TimeInterval

  /// The leeway for the underlying timer.
  private let leeway: TimerLeeway?

  /// The quality of service of the task.
  private let qos: DispatchQoS

  /// The flags of the underlying work item.
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
        ChouTi.assertFailure("delay seconds must be non-negative", metadata: ["delay": "\(delayedSeconds)"])
        return 0
      }
      guard delayedSeconds.isFinite else {
        ChouTi.assertFailure("delay seconds must be finite", metadata: ["delay": "\(delayedSeconds)"])
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
    taskLock.lock()
    if _isCanceled || _isExecuting || _isExecuted {
      taskLock.unlock()
      return
    }
    taskLock.unlock()

    guard let queue = self.queue else {
      ChouTi.assertFailure("queue is unavailable when scheduling")
      return
    }

    let workItem = DispatchWorkItem(qos: qos, flags: flags, block: { [weak self] in
      guard let self else {
        // can be nil if caller cancels task and set the task to nil
        return
      }

      taskLock.lock()
      guard self._isCanceled == false else {
        ChouTi.assertFailure("workItem shouldn't be canceled when executing")
        taskLock.unlock()
        return
      }
      guard self._isExecuted == false else {
        // early executed
        taskLock.unlock()
        return
      }

      self._isExecuting = true
      taskLock.unlock()

      self.task()

      taskLock.lock()
      self._isExecuting = false
      self._isExecuted = true

      // dispatch next task if has one
      if let nextTask = self.nextTask {
        nextTask.start()
      }
      taskLock.unlock()

      PrivateDelayTask.storeLock.withLock {
        ChouTi.assert(PrivateDelayTask.store[self.id] != nil, "store should have the task reference when just executed")
        PrivateDelayTask.store[self.id] = nil
      }
    })
    taskLock.lock()
    self.workItem = workItem
    taskLock.unlock()

    // store the task must happen before executing the task below, since tasks with 0 delay can execute synchronously.
    PrivateDelayTask.storeLock.withLock {
      ChouTi.assert(PrivateDelayTask.store[id] == nil, "store should not have the task reference when just started")
      PrivateDelayTask.store[id] = self
    }

    // schedule the task
    if delayedSeconds <= 0 {
      onQueueAsync(queue: queue, execute: workItem)
    } else {
      if let leeway {
        taskLock.lock()
        timer = DispatchTimer.delayTimer(after: delayedSeconds, isStrict: leeway.isStrict, leeway: leeway, queue: queue, block: { [weak workItem] in workItem.assert("workItem should not be nil when executing")?.perform() })
        taskLock.unlock()
      } else {
        onQueueAsync(queue: queue, delay: delayedSeconds, execute: workItem)
      }
    }
  }

  func execute() {
    taskLock.lock()
    if _isCanceled || _isExecuting || _isExecuted {
      taskLock.unlock()
      return
    }
    guard let workItem = self.workItem else {
      ChouTi.assertFailure("work item shouldn't be nil")
      taskLock.unlock()
      return
    }
    taskLock.unlock()

    guard let queue = self.queue else {
      ChouTi.assertFailure("execution queue is deallocated")
      return
    }

    onQueueAsync(queue: queue, execute: workItem)
  }

  func cancel() {
    taskLock.lock()
    if _isCanceled || _isExecuting || _isExecuted {
      taskLock.unlock()
      return
    }

    _isCanceled = true

    timer?.cancel()

    // workItem could be nil if not started yet
    workItem?.cancel()
    workItem = nil

    // cancel next task if has one
    if let nextTask {
      nextTask.cancel()
    }

    taskLock.unlock()

    PrivateDelayTask.storeLock.withLock {
      PrivateDelayTask.store[id] = nil
    }
  }
}

// MARK: - Then

extension PrivateDelayTask {

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
    taskLock.withLock {
      nextTask = task
    }
    return task
  }
}

// MARK: - Public Methods

/// Execute a task after a delay.
/// - Parameters:
///   - delayedSeconds: The delayed seconds.
///   - leeway: The leeway for the delay.
///   - qos: The quality of service of the task.
///   - flags: The flags of the underlying work item.
///   - queue: The dispatch queue to run on. Default is main queue.
///   - task: The closure to run.
/// - Returns: The delay task. The task is strongly retained.
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

/// Execute a task after a delay.
/// - Parameters:
///   - duration: The delayed duration.
///   - leeway: The leeway for the delay.
///   - qos: The quality of service of the task.
///   - flags: The flags of the underlying work item.
///   - queue: The dispatch queue to run on. Default is main queue.
///   - task: The closure to run.
/// - Returns: The delay task. The task is strongly retained.
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

/// Execute a task after a delay.
/// - Parameters:
///   - delayedSeconds: The delayed seconds.
///   - leeway: The leeway for the delay.
///   - qos: The quality of service of the task.
///   - flags: The flags of the underlying work item.
///   - queue: The dispatch queue to run on. Default is main queue.
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

/// Execute a task after a delay.
/// - Parameters:
///   - duration: The delayed duration.
///   - leeway: The leeway for the delay.
///   - qos: The quality of service of the task.
///   - flags: The flags of the underlying work item.
///   - queue: The dispatch queue to run on. Default is main queue.
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
