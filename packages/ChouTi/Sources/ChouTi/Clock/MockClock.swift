//
//  MockClock.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/31/24.
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

public class MockClock: Clock {

  private var currentTime: TimeInterval = 0
  private var scheduledTasks: [(TimeInterval, ValueCancellableToken<(DispatchWorkItem, DispatchQueue)>)] = []

  /// A temporary storage for tokens to avoid the tasks being cancelled.
  private var tokenStorage: [ObjectIdentifier: ValueCancellableToken<(DispatchWorkItem, DispatchQueue)>] = [:]

  public init(currentTime: TimeInterval = 0) {
    ChouTi.assert(currentTime >= 0, "currentTime must be greater than or equal to 0")
    self.currentTime = max(currentTime, 0)
  }

  public func now() -> TimeInterval {
    return currentTime
  }

  public func advance(by seconds: TimeInterval) {
    ChouTi.assert(seconds >= 0, "seconds must be greater than or equal to 0")
    currentTime += max(seconds, 0)
    executeScheduledTasks()
  }

  public func advance(to time: TimeInterval) {
    guard time > currentTime else {
      ChouTi.assertFailure("time must be greater than current time")
      return
    }
    currentTime = time
    executeScheduledTasks()
  }

  @discardableResult
  public func delay(_ delay: TimeInterval, queue: DispatchQueue, block: @escaping () -> Void) -> CancellableToken {
    let fireTime = currentTime + delay
    let task = DispatchWorkItem(block: block)
    let token = ValueCancellableToken(value: (task, queue)) { [weak self] token in
      token.value.0.cancel()
      self?.scheduledTasks.removeAll { $0.1 === token }
    }

    let insertionIndex = scheduledTasks.firstIndex(where: { $0.0 > fireTime }) ?? scheduledTasks.endIndex
    scheduledTasks.insert((fireTime, token), at: insertionIndex)

    return token
  }

  func executeScheduledTasks() {
    while let (fireTime, token) = scheduledTasks.first, fireTime <= currentTime {
      scheduledTasks.removeFirst()
      let (task, queue) = token.value

      tokenStorage[ObjectIdentifier(token)] = token // keep the task alive

      queue.asyncIfNeeded { [weak self] in
        task.perform()

        self?.tokenStorage[ObjectIdentifier(token)] = nil
      }
    }
  }

  // MARK: - Testing

  #if DEBUG

  var test: Test { Test(host: self) }

  class Test {

    private let host: MockClock

    fileprivate init(host: MockClock) {
      ChouTi.assert(Thread.isRunningXCTest, "test namespace should only be used in test target.")
      self.host = host
    }

    var scheduledTasks: [(TimeInterval, ValueCancellableToken<(DispatchWorkItem, DispatchQueue)>)] {
      host.scheduledTasks
    }

    var tokenStorage: [ObjectIdentifier: ValueCancellableToken<(DispatchWorkItem, DispatchQueue)>] {
      host.tokenStorage
    }
  }

  #endif
}
