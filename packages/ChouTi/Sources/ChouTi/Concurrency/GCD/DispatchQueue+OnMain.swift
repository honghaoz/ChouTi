//
//  DispatchQueue+OnMain.swift
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
