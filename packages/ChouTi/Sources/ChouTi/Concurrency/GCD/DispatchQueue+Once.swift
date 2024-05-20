//
//  DispatchQueue+Once.swift
//
//  Created by Honghao Zhang on 1/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension DispatchQueue {

  private static var _lock = UnfairLock()
  private static var _onceTracker = Set<AnyHashable>()

  /// Executes a block of code only once, based on the source code location.
  ///
  /// The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
  ///
  /// - Parameters:
  ///   - block: Block to execute once.
  /// - Returns: `true` if executed.
  @discardableResult
  static func once(file: StaticString = #fileID,
                   line: UInt = #line,
                   column: UInt = #column,
                   block: () -> Void) -> Bool
  {
    let token = "\(file):\(line):\(column)"
    return once(token: token, block: block)
  }

  /// Executes a block of code, associated with a unique token, only once.
  ///
  /// The code is thread safe and will only execute the code once even in the presence of multithreaded calls.
  ///
  /// Example:
  /// ```swift
  /// DispatchQueue.once(token: "io.chouti.magic-app.setup") {
  ///  // Do you one-time work...
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - token: A unique token. Generally, use reverse DNS style string such as "com.appleseed.<...>" or a GUID.
  ///   - block: Block to execute once.
  /// - Returns: `true` if executed.
  @discardableResult
  static func once(token: AnyHashable, block: () -> Void) -> Bool {
    _lock.lock()
    defer { _lock.unlock() }

    guard !_onceTracker.contains(token) else {
      return false
    }

    _onceTracker.insert(token)
    block()
    return true
  }

  /// Do once check, based on the source code location.
  ///
  /// Example:
  /// ```swift
  /// guard DispatchQueue.once() else {
  ///   return
  /// }
  ///
  /// // Do you one-time work...
  /// ```
  /// - Returns: `true` if can execute.
  static func once(file: StaticString = #fileID,
                   line: UInt = #line,
                   column: UInt = #column) -> Bool
  {
    let token = "\(file):\(line):\(column)"
    return once(token: token)
  }

  /// Do once check with a unique token.
  ///
  /// Example:
  /// ```swift
  /// guard DispatchQueue.once(token: "io.chouti.magic-app.setup") else {
  ///   return
  /// }
  ///
  /// // Do you one-time work...
  /// ```
  ///
  /// - Parameter token: A unique token. Generally, use reverse DNS style string such as "com.appleseed.<...>" or a GUID.
  /// - Returns: `true` if can execute.
  static func once(token: AnyHashable) -> Bool {
    _lock.lock()
    defer {
      _onceTracker.insert(token)
      _lock.unlock()
    }
    return !_onceTracker.contains(token)
  }
}

extension DispatchQueue {

  private static var _onceAssertTracker = Set<AnyHashable>()

  fileprivate static func guaranteeOneTimeCall(token: AnyHashable) {
    if _onceAssertTracker.contains(token) {
      ChouTi.assertFailure("should only call once, token: \(token)")
      return
    } else {
      _onceAssertTracker.insert(token)
    }
  }
}

/// Asserts that the code is only executed once, based on the source code location.
///
/// This is useful for one-time setup code.
///
/// Example:
/// ```swift
/// func setupMethodSwizzle() {
///   assertOnce()
///   // Do your one-time setup...
/// }
/// ```
public func assertOnce(file: StaticString = #fileID,
                       line: UInt = #line,
                       column: UInt = #column)
{
  assertOnce(token: "\(file):\(line):\(column)")
}

/// Asserts that the code is only executed once, based on a unique token.
///
/// This is useful for one-time setup code.
///
/// Example:
/// ```swift
/// func setupMethodSwizzle() {
///   assertOnce(token: "io.chouti.magic-app.swizzle")
///   // Do your one-time setup...
/// }
/// ```
public func assertOnce(token: AnyHashable) {
  DispatchQueue.guaranteeOneTimeCall(token: token)
}

// https://stackoverflow.com/a/39983813/3164091
