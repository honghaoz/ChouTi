//
//  UnfairLock.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/28/21.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
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
import os.lock

/// `UnfairLock` is a wrapper of `os_unfair_lock`, which provides a lightweight, fast, and efficient implementation of
/// a lock for synchronization purposes in Swift.
///
/// Usage:
/// ```
/// let lock = UnfairLock()
///
/// func performThreadSafeOperation() {
///   lock.withLock {
///     // Perform operations that require synchronized access.
///    }
///  }
/// ```
///
/// Use `OSAllocatedUnfairLock` for iOS 16.0+ and macOS 13.0+.
public final class UnfairLock: NSLocking {

  @usableFromInline
  let unfairLock: UnsafeMutablePointer<os_unfair_lock>

  /// Creates a new `UnfairLock`.
  public init() {
    unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
    unfairLock.initialize(to: os_unfair_lock())
  }

  deinit {
    unfairLock.deinitialize(count: 1)
    unfairLock.deallocate()
  }

  /// Acquires the lock. If the lock is already acquired, the calling thread will be blocked until the lock becomes available.
  @inlinable
  @inline(__always)
  public func lock() {
    os_unfair_lock_lock(unfairLock)
  }

  /// Attempts to acquire the lock without blocking. If the lock is available, it acquires the lock and returns true.
  /// If the lock is not available, it returns false.
  @inlinable
  @inline(__always)
  public func tryLock() -> Bool {
    os_unfair_lock_trylock(unfairLock)
  }

  /// Releases the lock. This must only be called by the thread that owns the lock.
  @inlinable
  @inline(__always)
  public func unlock() {
    os_unfair_lock_unlock(unfairLock)
  }

  /// Executes the given closure while the lock is held.
  ///
  /// The lock is acquired before the closure is executed and released after the closure is executed.
  ///
  /// - Parameter block: The block to execute.
  /// - Returns: The result of the closure. If the closure throws an error, the method rethrows the error.
  public func withLock<R>(_ block: () throws -> R) rethrows -> R {
    lock()
    defer { unlock() }

    return try block()
  }
}

/// References:
/// - https://stackoverflow.com/a/58211849/3164091
/// - https://stackoverflow.com/a/66525671/3164091
/// - https://swiftrocks.com/thread-safety-in-swift
/// - https://gist.github.com/tclementdev/6af616354912b0347cdf6db159c37057
/// - https://developer.apple.com/forums/thread/712379
