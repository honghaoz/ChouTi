//
//  Binding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/27/22.
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
import CoreGraphics
import Foundation

/// A type that can read and write a value owned by a source of truth.
///
/// Two modes:
/// 1. stored value. PropertyWrapper uses this mode.
/// 2. external value, via `get`, `set` blocks.
@propertyWrapper
public final class Binding<T>: MutableBindingType, InternalBindingType {

  // MARK: - Public

  /// Indicates whether the binding is currently paused and not accepting new value assignments.
  ///
  /// When this is `true`, attempts to set a new value will be ignored.
  /// Use `pause()` and `resume()` methods to control this state.
  public private(set) var isPaused: Bool = false

  // MARK: - Private

  private lazy var implementation = BindingImplementation<T>(binding: self)

  // MARK: - Init (self contained value)

  private var _value: T?

  /// Initialize with a stored value.
  ///
  /// - Parameter value: The stored value.
  public init(_ value: T) {
    self._value = value
    self._get = nil
    self._set = nil
  }

  // MARK: - Init (from external provider)

  private let _get: (() -> T)?
  private let _set: ((T) -> Void)?

  /// Initialize with setter & getter.
  ///
  /// - Parameters:
  ///   - get: The getter for value.
  ///   - set: The setter for value.
  public init(get: @escaping () -> T, set: @escaping (T) -> Void) {
    self._value = nil
    self._get = get
    self._set = set
  }

  // MARK: - Property Wrapper

  public var wrappedValue: T {
    get {
      value
    }
    set {
      value = newValue
    }
  }

  public convenience init(wrappedValue: T) {
    self.init(wrappedValue)
  }

  public var projectedValue: Binding<T> {
    self
  }

  // MARK: - InternalBindingType

  func _removeRegisteredObservation(_ observation: BindingObservation) {
    implementation.removeRegisteredObservation(observation)
  }

  // MARK: - BindingType

  /// The current value of the binding.
  public var value: T {
    get {
      if let value = _value {
        return value
      } else if let get = _get {
        return get()
      } else {
        fatalError("unexpected") // swiftlint:disable:this fatal_error
      }
    }
    set {
      guard isPaused == false else {
        return
      }

      if _value != nil {
        _value = newValue
      } else if let set = _set {
        set(newValue)
      } else {
        // swiftlint:disable:next fatal_error
        fatalError("unexpected")
      }

      implementation.invoke(with: newValue)
    }
  }

  /// A publisher that emits the current value of the binding.
  ///
  /// The publisher will emit the current value immediately when there's a subscriber.
  public var publisher: AnyPublisher<T, Never> {
    implementation.publisher
  }

  /// Observes the binding for value changes.
  ///
  /// - Parameter block: A closure that will be called when the binding's value changes. The closure provides a cancel handler to stop observing.
  /// - Returns: An observation as a token that can be used to stop observing.
  public func observe(_ block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    implementation.observe(binding: self, block: block)
  }

  /// Observes the binding for value changes.
  ///
  /// - Parameter block: A closure that will be called when the binding's value changes.
  /// - Returns: An observation as a token that can be used to stop observing.
  public func observe(_ block: @escaping (_ value: T) -> Void) -> BindingObservation {
    implementation.observe(binding: self, block: block)
  }

  // MARK: - Pause/Resume

  /// Pause the binding from updating its value.
  ///
  /// This will prevent the binding from updating its value. `isPaused` will be set to `true`.
  public func pause() {
    isPaused = true
  }

  /// Resume the binding from updating its value.
  ///
  /// This will allow the binding to update its value. `isPaused` will be set to `false`.
  public func resume() {
    isPaused = false
  }

  // MARK: - Subscribe

  /// Subscribes self to a source binding, so that if the source binding updates, self is updated.
  ///
  /// ⚠️ It's a programming error if your create binding subscription loops.
  ///
  /// Memory Notes:
  /// - The returned `BindingObservation` needs to be strongly retained to keep the subscription alive.
  /// - The returned `BindingObservation` keeps a strong reference to the source binding.
  ///
  /// - Parameters:
  ///   - source: A source binding, which can update to self.
  /// - Returns: An observation.
  public func subscribe(to source: some BindingType<T>) -> BindingObservation {
    // TODO: can detect binding loop and post error. can use throw

    let sourceObservation = source.observe { [weak self] value in
      guard let self else {
        ChouTi.assertFailure("downstream is nil, the source binding's observation should've be torn down")
        return
      }
      self.value = value
    }

    return sourceObservation
  }

  // MARK: - Connect

  /// Connects two bindings, so that one binding's value update will update the other one.
  ///
  /// ⚠️ It's a programming error if you connect same two bindings more than once.
  ///
  /// Memory Notes:
  /// - The returned `BindingObservation` needs to be strongly retained to keep the connection alive.
  /// - The returned `BindingObservation` keeps strong references to the two bindings in question.
  ///
  /// Other Notes:
  /// - Two bindings won't sync on connect. The first value emission from one binding will change the other one's value.
  /// - No memory reference between two bindings. It's the caller's responsibility to keep two bindings alive.
  ///
  /// - Parameters:
  ///   - binding: A binding to connect with `self`.
  ///   - mapTo: The transform closure to convert the value from `self` to the `binding`'s value type.
  ///   - setBack: The transform closure to convert the value from `binding` to `self`'s value type.
  /// - Returns: An observation.
  public func connect<U>(to binding: Binding<U>, mapTo: @escaping (T) -> U, setBack: @escaping (U) -> T) -> BindingObservation {

    let binding1 = self
    let binding2 = binding

    let binding1ObservationBox = WeakBox<BindingObservation>(nil)
    let binding2ObservationBox = WeakBox<BindingObservation>(nil)

    // from self -> another
    let binding1Observation = binding1.observe { [weak binding2, binding2ObservationBox] value in
      guard let binding2, let binding2Observation = binding2ObservationBox.object else {
        ChouTi.assertFailure("binding2 is nil, the binding1's observation should've be torn down")
        return
      }

      binding2Observation.pause()
      binding2.value = mapTo(value)
      binding2Observation.resume()
    }
    binding1ObservationBox.object = binding1Observation

    // from another -> self
    let binding2Observation = binding2.observe { [weak binding1, binding1ObservationBox] value in
      guard let binding1, let binding1Observation = binding1ObservationBox.object else {
        ChouTi.assertFailure("binding1 is nil, the binding2's observation should've be torn down")
        return
      }

      binding1Observation.pause()
      binding1.value = setBack(value)
      binding1Observation.resume()
    }
    binding2ObservationBox.object = binding2Observation

    binding1.onDeallocate { [binding2ObservationBox] in
      binding2ObservationBox.object?.cancel()
    }

    binding2.onDeallocate { [binding1ObservationBox] in
      binding1ObservationBox.object?.cancel()
    }

    return AggregatedBindingObservation(observations: [binding1Observation, binding2Observation])
  }

  /// Connects self to another binding, so that both bindings are synced.
  ///
  /// Two bindings won't sync immediately on connect. The first value emission from one binding will change the other one's value.
  ///
  /// - Parameters:
  ///   - binding: Another binding.
  /// - Returns: An observation.
  @discardableResult
  public func connect(to binding: Binding<T>) -> BindingObservation {
    connect(to: binding, mapTo: { $0 }, setBack: { $0 })
  }
}

public extension Binding where T == Bool {

  /// Toggle the binding's boolean value.
  @inlinable
  @inline(__always)
  func toggle() {
    value.toggle()
  }
}

public extension Binding where T == Void {

  /// Initialize a binding with `Void` type.
  convenience init() {
    self.init(())
  }

  /// Send a value.
  func send() {
    value = ()
  }
}

// MARK: - Extends CurrentValueSubject

public extension Binding {

  /// Initialize a binding from a `CurrentValueSubject`.
  ///
  /// The binding will hold a strong reference to the subject.
  ///
  /// - Parameter subject: The subject.
  @inlinable
  @inline(__always)
  convenience init(subject: CurrentValueSubject<T, Never>) {
    self.init(
      get: { subject.value },
      set: { subject.value = $0 }
    )
  }
}

public extension CurrentValueSubject where Failure == Never {

  /// Make a binding from a `CurrentValueSubject`.
  ///
  /// The returned binding will hold a strong reference to the subject.
  @inlinable
  @inline(__always)
  var binding: Binding<Output> {
    Binding<Output>(subject: self)
  }
}

// MARK: - Expressible

// Bool

extension Binding: ExpressibleByBooleanLiteral where T == Bool {

  public typealias BooleanLiteralType = T

  public convenience init(booleanLiteral value: T) {
    self.init(value)
  }
}

// Numbers

extension Binding: ExpressibleByIntegerLiteral where T == Int {

  public typealias IntegerLiteralType = T

  public convenience init(integerLiteral value: T) {
    self.init(value)
  }
}

extension Binding: ExpressibleByFloatLiteral where T == Double {

  public typealias FloatLiteralType = T

  public convenience init(floatLiteral value: T) {
    self.init(value)
  }
}

// String

extension Binding: ExpressibleByUnicodeScalarLiteral where T == String {

  public typealias UnicodeScalarLiteralType = String

  public convenience init(unicodeScalarLiteral value: T) {
    self.init(value)
  }
}

extension Binding: ExpressibleByExtendedGraphemeClusterLiteral where T == String {

  public typealias ExtendedGraphemeClusterLiteralType = T

  public convenience init(extendedGraphemeClusterLiteral value: T) {
    self.init(value)
  }
}

extension Binding: ExpressibleByStringLiteral where T == String {

  public typealias StringLiteralType = T

  public convenience init(stringLiteral value: T) {
    self.init(value)
  }
}
