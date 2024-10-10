//
//  AssertOnQueue.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/3/21.
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

/// Assert current queue is on the specified queue.
/// - Parameters:
///   - queue: The queue to assert on.
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertOnQueue(_ queue: DispatchQueue,
                          _ message: @autoclosure () -> String? = nil,
                          file: StaticString = #fileID,
                          line: UInt = #line,
                          column: UInt = #column,
                          function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(
    DispatchQueue.isOnQueue(queue, file: file, line: line, column: column),
    "Should be on queue: \(queue.label). Message: \"\(message() ?? "")\"",
    metadata: [
      "queue": "\(DispatchQueue.currentQueueLabel)",
      "thread": "\(Thread.current)",
    ],
    file: file,
    line: line,
    column: column,
    function: function
  )
  // dispatchPrecondition(condition: .onQueue(queue))
  #endif
}

/// Assert current queue is **NOT** on the specified queue.
/// - Parameters:
///   - queue: The queue to assert **NOT** on.
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertNotOnQueue(_ queue: DispatchQueue,
                             _ message: @autoclosure () -> String? = nil,
                             file: StaticString = #fileID,
                             line: UInt = #line,
                             column: UInt = #column,
                             function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(
    !DispatchQueue.isOnQueue(queue, file: file, line: line, column: column),
    "Should NOT be on queue: \(queue.label). Message: \"\(message() ?? "")\"",
    metadata: [
      "queue": "\(DispatchQueue.currentQueueLabel)",
      "thread": "\(Thread.current)",
    ],
    file: file,
    line: line,
    column: column,
    function: function
  )
  // not sure why the below doesn't work.
  // dispatchPrecondition(condition: .notOnQueue(queue))
  #endif
}

/// Assert current queue is on the Swift async/await cooperative queues.
/// - Parameters:
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertOnCooperativeQueue(_ message: @autoclosure () -> String? = nil,
                                     file: StaticString = #fileID,
                                     line: UInt = #line,
                                     column: UInt = #column,
                                     function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(
    DispatchQueue.isOnCooperativeQueue(),
    "Should be on cooperative queue. Message: \"\(message() ?? "")\"",
    metadata: [
      "queue": "\(DispatchQueue.currentQueueLabel)",
      "thread": "\(Thread.current)",
    ],
    file: file,
    line: line,
    column: column,
    function: function
  )
  #endif
}

/// Assert current queue is **NOT** on the Swift async/await cooperative queues.
/// - Parameters:
///   - message: The message to show when assertion fails.
@inlinable
@inline(__always)
public func assertNotOnCooperativeQueue(_ message: @autoclosure () -> String? = nil,
                                        file: StaticString = #fileID,
                                        line: UInt = #line,
                                        column: UInt = #column,
                                        function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(
    !DispatchQueue.isOnCooperativeQueue(),
    "Should NOT be on cooperative queue. Message: \"\(message() ?? "")\"",
    metadata: [
      "queue": "\(DispatchQueue.currentQueueLabel)",
      "thread": "\(Thread.current)",
    ],
    file: file,
    line: line,
    column: column,
    function: function
  )
  #endif
}
