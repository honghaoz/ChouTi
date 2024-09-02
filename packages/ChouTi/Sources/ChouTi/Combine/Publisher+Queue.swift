//
//  Publisher+Queue.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/21/22.
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

import Combine
import Foundation

public extension Publisher {

  /// Dispatch the received elements from the publisher to the specified queue.
  ///
  /// - Parameter queue: The queue to dispatch.
  /// - Returns: A publisher.
  @inlinable
  @inline(__always)
  func receive(on queue: DispatchQueue) -> Publishers.ReceiveOn<Self, DispatchQueue> {
    receive(on: queue, options: nil)
  }

  /// Dispatch the received elements from the publisher to the specified queue.
  ///
  /// - Parameters:
  ///   - queue: The queue to dispatch.
  ///   - qos: The dispatch queue quality of service.
  ///   - flags: The dispatch queue work item flags.
  ///   - group: The dispatch group, if any, to use when performing actions.
  /// - Returns: A publisher.
  @inlinable
  @inline(__always)
  func receive(on queue: DispatchQueue,
               qos: DispatchQoS = .unspecified,
               flags: DispatchWorkItemFlags = [],
               group: DispatchGroup? = nil) -> Publishers.ReceiveOn<Self, DispatchQueue>
  {
    receive(on: queue, options: DispatchQueue.SchedulerOptions(qos: qos, flags: flags, group: group))
  }

  /// Dispatches received values to the specified queue, with an option for immediate execution if already on the target queue.
  ///
  /// This method optimizes performance by avoiding unnecessary queue switching when the publisher
  /// is already operating on the target queue. It provides control over whether to always dispatch
  /// asynchronously or allow immediate execution in same-queue scenarios.
  ///
  /// Example:
  /// ```swift
  /// somePublisher
  ///   .receive(on: .main, alwaysAsync: false)
  ///   .sink { value in
  ///     // update UI...
  ///   }
  /// ```
  ///
  /// - Parameters:
  ///   - queue: The queue to which received values should be dispatched.
  ///   - alwaysAsync: If `true`, received values will always be dispatched asynchronously, even if already on the target queue.
  ///                  If `false`, received values will be dispatched immediately if already on the target queue.
  /// - Returns: A publisher.
  func receive(on queue: DispatchQueue, alwaysAsync: Bool) -> Publishers.FlatMap<AnyPublisher<Self.Output, Self.Failure>, Self> {
    flatMap { value -> AnyPublisher<Self.Output, Self.Failure> in
      if !alwaysAsync, DispatchQueue.isOnQueue(queue) {
        return Just(value)
          .setFailureType(to: Self.Failure.self)
          .eraseToAnyPublisher()
      } else {
        return Just(value)
          .setFailureType(to: Self.Failure.self)
          .receive(on: queue)
          .eraseToAnyPublisher()
      }
    }
  }
}

/// References:
/// https://forums.swift.org/t/how-to-make-receive-on-deliver-value-immediately-if-already-on-the-correct-scheduler/46819/2
