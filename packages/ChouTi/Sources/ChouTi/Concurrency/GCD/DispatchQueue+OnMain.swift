//
//  DispatchQueue+OnMain.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchQueue {

  /// Dispatch the block to main queue asynchronously if needed.
  /// - Parameters:
  ///   - delay: The time after which the block will be executed. Default value is `nil`, no delay.
  ///   - qos: The quality-of-service class. Default value is `.unspecified`.
  ///   - flags: The flags for the underlying work item. Default value is `[]`.
  ///   - block: The block to be executed.
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

  /// Dispatch the work item to main queue asynchronously if needed.
  /// - Parameters:
  ///   - delay: The time after which the work item will be executed. Default value is `nil`, no delay.
  ///   - workItem: The work item to be executed.
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
  ///
  /// If the current thread is main thread, the block will be executed immediately. This avoids deadlock.
  ///
  /// - Parameter block: The block to be executed.
  /// - Returns: The result of the block.
  static func onMainSync<T>(_ block: @escaping () throws -> T) rethrows -> T {
    if Thread.isMainThread {
      return try block()
    } else {
      return try DispatchQueue.main.sync(execute: block)
    }
  }
}

/// Dispatch the block to main queue asynchronously if needed.
/// - Parameters:
///   - delay: The time after which the block will be executed. Default value is `nil`, no delay.
///   - qos: The quality-of-service for the block. Default value is `.unspecified`.
///   - flags: The flags for the underlying work item. Default value is `[]`.
///   - block: The block to be executed.
@inlinable
@inline(__always)
public func onMainAsync(delay: TimeInterval? = nil, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], execute block: @escaping () -> Void) {
  DispatchQueue.onMainAsync(delay: delay, qos: qos, flags: flags, execute: block)
}

/// Dispatch the work item to main queue asynchronously if needed.
/// - Parameters:
///   - delay: The time after which the work item will be executed. Default value is `nil`, no delay.
///   - workItem: The work item to be executed.
@inlinable
@inline(__always)
public func onMainAsync(delay: TimeInterval? = nil, execute workItem: DispatchWorkItem) {
  DispatchQueue.onMainAsync(delay: delay, execute: workItem)
}

/// Dispatch the block to main queue synchronously if needed.
/// - Parameter block: The block to be executed.
/// - Returns: The result of the block.
@inlinable
@inline(__always)
public func onMainSync<T>(_ block: @escaping () throws -> T) rethrows -> T {
  try DispatchQueue.onMainSync(block)
}
