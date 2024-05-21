//
//  DispatchQueue+OnMain.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchQueue {

  /// Dispatch the block to main queue asynchronously if needed.
  ///
  /// If current thread is main thread and no delay, the block will execute immediately.
  ///
  /// - Parameters:
  ///   - delay: A delay time before execution.
  ///   - block: The block to execute.
  static func onMainAsync(delay: TimeInterval? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute block: @escaping () -> Void) {
    if let delay, delay > 0 {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay, qos: qos, flags: flags, execute: block)
    } else {
      if Thread.isMainThread {
        block()
      } else {
        DispatchQueue.main.async(qos: qos, flags: flags, execute: block)
      }
    }
  }

  static func onMainAsync(delay: TimeInterval? = nil, execute workItem: DispatchWorkItem) {
    if let delay, delay > 0 {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    } else {
      if Thread.isMainThread {
        workItem.perform()
      } else {
        DispatchQueue.main.async(execute: workItem)
      }
    }
  }

  /// Dispatch the block to main queue synchronously if needed.
  static func onMainSync<T>(_ block: @escaping () throws -> T) rethrows -> T {
    if Thread.isMainThread {
      return try block()
    } else {
      return try DispatchQueue.main.sync(execute: block)
    }
  }
}

/// Dispatch the block to main queue asynchronously if needed.
///
/// If current thread is main thread and no delay, the block will execute immediately.
///
/// - Parameters:
///   - delay: A delay time before execution.
///   - block: The block to execute.
@inlinable
@inline(__always)
public func onMainAsync(delay: TimeInterval? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute block: @escaping () -> Void) {
  DispatchQueue.onMainAsync(delay: delay, qos: qos, flags: flags, execute: block)
}

@inlinable
@inline(__always)
public func onMainAsync(delay: TimeInterval? = nil, execute workItem: DispatchWorkItem) {
  DispatchQueue.onMainAsync(delay: delay, execute: workItem)
}

@inlinable
@inline(__always)
public func onMainSync<T>(_ block: @escaping () throws -> T) rethrows -> T {
  try DispatchQueue.onMainSync(block)
}
