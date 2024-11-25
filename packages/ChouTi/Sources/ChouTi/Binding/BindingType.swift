//
//  BindingType.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/31/23.
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

/// A type that can be observed.
public protocol BindingType<Value>: AnyObject, Hashable, DeallocationNotifiable, BindingStorageProviding, TypeEraseWrapperBaseType {

  associatedtype Value

  /// The binding's value.
  var value: Value { get }

  /// Get a Combine publisher for the binding.
  ///
  /// ⚠️ The binding object must be retained to keep the publisher working. For example, for a mapped binding, you need
  /// to make sure the intermediate mapped bindings are alive to keep the publisher working.
  ///
  /// The publisher emits current value when subscribes. Use `dropFirst()` to skip the current value.
  /// ```
  /// binding
  ///   .publisher
  ///   .dropFirst()
  /// ```
  var publisher: AnyPublisher<Value, Never> { get }

  /// Make a new observation.
  ///
  /// The returned `BindingObservation` should be strongly retained to keep the observation alive.
  /// You can use `BindingObservationStorage` and `BindingObservationStorageProviding` to manage the observation.
  ///
  /// The returned `BindingObservation` strongly retains the upstream binding.
  ///
  /// Example:
  /// ```
  /// // using the cancel handle can set up a one-time observation
  /// binding
  ///   .observe { value, cancel in
  ///     // ...
  ///
  ///     cancel() // cancel this observation
  ///   }
  ///   .store(in: .shared) // store in the shared storage
  /// ```
  /// - Parameters:
  ///   - block: The value update block, passes into the value and a cancel handle to cancel the observation.
  func observe(_ block: @escaping (_ value: Value, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation

  /// Make a new observation.
  ///
  /// The returned `BindingObservation` should be strongly retained to keep the observation alive.
  /// You can use `BindingObservationStorage` and `BindingObservationStorageProviding` to manage the observation.
  ///
  /// The returned `BindingObservation` strongly retains the upstream binding.
  ///
  /// - Parameters:
  ///   - block: The value update block.
  func observe(_ block: @escaping (_ value: Value) -> Void) -> BindingObservation

  /// Store the binding in a binding storage.
  ///
  /// - Parameters:
  ///   - storage: A binding storage.
  /// - Returns: `self`.
  @discardableResult
  func store(in storage: BindingStorage) -> Self
}

public extension BindingType {

  func store(in storage: BindingStorage) -> Self {
    storage.store(self)
    return self
  }

  // MARK: - Hashable

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  // MARK: - Equatable

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs === rhs
  }

  // MARK: - TypeEraseWrapperBaseType

  func `as`<T>(_ type: T.Type) -> T? {
    if let selfAsT = self as? T {
      return selfAsT
    } else if let anyShape = self as? AnyBinding<Value>,
              let casted = anyShape.wrapped as? T
    {
      return casted
    }
    return nil
  }
}

public extension BindingType {

  /// Return a binding that emits its current value immediately when observes.
  ///
  /// - Returns: A new binding.
  func emitCurrentValue() -> some BindingType<Value> {
    ImmediateBinding(upstreamBinding: self)
  }

  /// Make a unidirectional mapped binding. Updating self updates the returned binding, but not the other way around.
  ///
  /// Note:
  /// - The returned binding holds a strong reference to the upstream binding.
  /// - Internally, the upstream binding creates an observation that emits values to the returned binding.
  /// - The internal observation is stored in the returned binding, releases the returned binding will clear the upstream binding's observation.
  ///
  /// - Parameters:
  ///   - map: The transform function.
  /// - Returns: A new binding.
  func map<U>(_ map: @escaping (Value) -> U) -> some BindingType<U> {
    TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { map($0) },
        upstreamValueChanged: { $1(map($0)) }
      )
    )
  }

  /// Remove duplicated value update.
  ///
  /// Note:
  /// - The returned binding holds a strong reference to the upstream binding.
  /// - Internally, the upstream binding creates an observation that emits values to the returned binding.
  /// - The internal observation is stored in the returned binding, releases the returned binding will clear the upstream binding's observation.
  ///
  /// - Parameters:
  ///   - predicate: A closure to evaluate whether two elements are equivalent, for purposes of filtering. Return true from this closure to indicate that the second element is a duplicate of the first.
  /// - Returns: A new binding
  func removeDuplicates(by predicate: @escaping (Value, Value) -> Bool) -> some BindingType<Value> {
    var oldValueOrNil: Value?

    return TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { upstreamValue in
          oldValueOrNil = upstreamValue
          return upstreamValue
        },
        upstreamValueChanged: { newValue, setTransformedValue in
          guard let oldValue = oldValueOrNil else {
            oldValueOrNil = newValue
            setTransformedValue(newValue)
            return
          }

          if !predicate(oldValue, newValue) {
            oldValueOrNil = newValue
            setTransformedValue(newValue)
          }
        }
      )
    )
  }

  /// Set observation block invoking queue.
  ///
  /// - Parameters:
  ///   - queue: The queue to invoke observation blocks.
  ///   - alwayAsync: If should always invoke asynchronously. Default value is `false`.
  ///                 For example, if the `queue` is `main` and if the binding value is mutated on the main queue, using `false` will invoke observation blocks synchronously.
  /// - Returns: A new binding.
  func receive(on queue: DispatchQueue, alwayAsync: Bool = false) -> some BindingType<Value> {
    TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { $0 },
        upstreamValueChanged: { newValue, setTransformedValue in
          if alwayAsync {
            queue.async {
              setTransformedValue(newValue)
            }
          } else {
            onQueueAsync(queue: queue) {
              setTransformedValue(newValue)
            }
          }
        }
      )
    )
  }

  /// Delay the observation block invocation.
  ///
  /// - Parameters:
  ///   - delay: The delay time interval in seconds. If the delay is 0 or negative, the observation block is executed on the queue asynchronously if needed.
  ///   - queue: The queue to invoke the observation blocks.
  /// - Returns: A new binding.
  func delay(_ delay: TimeInterval, receiveOn queue: DispatchQueue) -> some BindingType<Value> {
    TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { $0 },
        upstreamValueChanged: { newValue, setTransformedValue in
          if delay > 0 {
            ClockProvider.current.delay(delay, queue: queue) {
              setTransformedValue(newValue)
            }
          } else {
            onQueueAsync(queue: queue) {
              setTransformedValue(newValue)
            }
          }
        }
      )
    )
  }

  /// Debounce (leading) the observation block invocation.
  ///
  /// - Parameter interval: The debounce interval.
  /// - Returns: A new binding.
  func leadingDebounce(for interval: TimeInterval) -> some BindingType<Value> {
    let debouncer = LeadingDebouncer(interval: interval)
    return TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { $0 },
        upstreamValueChanged: { newValue, setTransformedValue in
          guard debouncer.debounce() else {
            return
          }
          setTransformedValue(newValue)
        }
      )
    )
  }

  /// Debounce (trailing) the observation block invocation.
  ///
  /// - Parameters:
  ///   - interval: The debounce interval.
  ///   - queue: The observation invocation queue.
  /// - Returns: A new binding.
  func trailingDebounce(for interval: TimeInterval, queue: DispatchQueue) -> some BindingType<Value> {
    let debouncer = TrailingDebouncer(interval: interval, queue: queue)
    return TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { $0 },
        upstreamValueChanged: { newValue, setTransformedValue in
          debouncer.debounce {
            setTransformedValue(newValue)
          }
        }
      )
    )
  }

  /// Throttle the observation block invocation.
  ///
  /// - Parameters:
  ///   - interval: The throttling interval.
  ///   - latest: If should invoke the observation block with the latest value during the throttling duration.
  ///   - invokeImmediately: If should invoke the observation block immediately if the time interval is already passed since the last fire time. Default value is `false`.
  ///   - queue: The observation invocation queue.
  /// - Returns: A new binding.
  func throttle(for interval: TimeInterval, latest: Bool, invokeImmediately: Bool = false, queue: DispatchQueue) -> some BindingType<Value> {
    let throttler = Throttler(interval: interval, latest: latest, invokeImmediately: invokeImmediately, queue: queue)
    return TransformedBinding(
      upstreamBinding: self,
      transformer: BindingTransformer(
        getInitialValue: { $0 },
        upstreamValueChanged: { newValue, setTransformedValue in
          throttler.throttle {
            setTransformedValue(newValue)
          }
        }
      )
    )
  }

  /// Make a new binding that is combined from `self` and `another` binding.
  ///
  /// ```
  /// T --+
  ///     |--> (T, U)
  /// U --+
  /// ```
  ///
  /// Note:
  /// - The resulted binding holds strong references to the two upstream bindings.
  ///
  /// - Parameter another: Another binding to combine with.
  /// - Returns: A new combined binding.
  func combine<U>(with another: some BindingType<U>) -> some BindingType<(Value, U)> {
    CombinedBinding(upstreamBinding1: self, upstreamBinding2: another)
  }
}

public extension BindingType where Value: Equatable {

  /// Remove duplicated value update.
  ///
  /// - Returns: A new binding.
  @inlinable
  @inline(__always)
  func removeDuplicates() -> some BindingType<Value> {
    removeDuplicates(by: { $0 == $1 })
  }
}

/// References:
/// - Primary associated types in Swift 5.7
///   - https://www.donnywals.com/what-are-primary-associated-types-in-swift-5-7/
///   - https://www.avanderlee.com/swift/some-opaque-types/
///   - https://github.com/apple/swift-evolution/blob/main/proposals/0341-opaque-parameters.md
///   - https://github.com/apple/swift-evolution/blob/main/proposals/0346-light-weight-same-type-syntax.md
///   - https://github.com/apple/swift-evolution/blob/main/proposals/0358-primary-associated-types-in-stdlib.md
