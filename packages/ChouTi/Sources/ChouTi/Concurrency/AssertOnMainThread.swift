//
//  AssertOnMainThread.swift
//
//  Created by Honghao Zhang on 10/31/22.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

@inlinable
@inline(__always)
public func assertOnMainThread(_ message: @autoclosure () -> String = String(),
                               file: StaticString = #fileID,
                               line: UInt = #line,
                               column: UInt = #column,
                               function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(Thread.isMainThread, "Should be on main thread. Current thread: \(Thread.current). Current queue label: \"\(DispatchQueue.currentQueueLabel)\". Message: \"\(message())\".", file: file, line: line, column: column, function: function)
  #endif
}

@inlinable
@inline(__always)
public func assertNotOnMainThread(_ message: @autoclosure () -> String = String(),
                                  file: StaticString = #fileID,
                                  line: UInt = #line,
                                  column: UInt = #column,
                                  function: StaticString = #function)
{
  #if DEBUG
  ChouTi.assert(!Thread.isMainThread, "Should NOT be on main thread. Current thread: \(Thread.current). Current queue label: \"\(DispatchQueue.currentQueueLabel)\". Message: \"\(message())\".", file: file, line: line, column: column, function: function)
  #endif
}
