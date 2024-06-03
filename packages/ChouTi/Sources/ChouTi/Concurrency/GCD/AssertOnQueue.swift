//
//  AssertOnQueue.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// Assert current queue is on the specified queue.
/// - Parameters:
///   - queue: The queue to assert on.
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertOnQueue(_ queue: DispatchQueue,
                          _ message: @autoclosure () -> String = String(),
                          file: StaticString = #fileID,
                          line: UInt = #line,
                          column: UInt = #column,
                          function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(DispatchQueue.isOnQueue(queue, file: file, line: line, column: column), "Should be on queue: \(queue.label). Current queue label: \"\(DispatchQueue.currentQueueLabel)\". Message: \(message())", file: file, line: line, column: column, function: function)
  dispatchPrecondition(condition: .onQueue(queue))
  #endif
}

/// Assert current queue is **NOT** on the specified queue.
/// - Parameters:
///   - queue: The queue to assert **NOT** on.
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertNotOnQueue(_ queue: DispatchQueue,
                             _ message: @autoclosure () -> String = String(),
                             file: StaticString = #fileID,
                             line: UInt = #line,
                             column: UInt = #column,
                             function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(!DispatchQueue.isOnQueue(queue, file: file, line: line, column: column), "Should be NOT on queue: \(queue.label). Current queue label: \"\(DispatchQueue.currentQueueLabel)\". Message: \(message())", file: file, line: line, column: column, function: function)
  // not sure why the below doesn't work.
  // dispatchPrecondition(condition: .notOnQueue(queue))
  #endif
}

/// Assert current queue is on the Swift async/await cooperative queues.
/// - Parameters:
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertOnCooperativeQueue(_ message: @autoclosure () -> String = String(),
                                     file: StaticString = #fileID,
                                     line: UInt = #line,
                                     column: UInt = #column,
                                     function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(DispatchQueue.isOnCooperativeQueue(), "Should be on cooperative queue. Current thread: \(Thread.current). Current queue label: \"\(DispatchQueue.currentQueueLabel)\". Message: \"\(message())\".", file: file, line: line, column: column, function: function)
  #endif
}

/// Assert current queue is **NOT** on the Swift async/await cooperative queues.
/// - Parameters:
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertNotOnCooperativeQueue(_ message: @autoclosure () -> String = String(),
                                        file: StaticString = #fileID,
                                        line: UInt = #line,
                                        column: UInt = #column,
                                        function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(!DispatchQueue.isOnCooperativeQueue(), "Should NOT be on cooperative queue. Current thread: \(Thread.current). Current queue label: \"\(DispatchQueue.currentQueueLabel)\". Message: \"\(message())\".", file: file, line: line, column: column, function: function)
  #endif
}
