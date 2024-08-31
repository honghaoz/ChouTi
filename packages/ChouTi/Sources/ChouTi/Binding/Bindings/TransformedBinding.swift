//
//  TransformedBinding.swift
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

/// A binding that supports value transforms.
final class TransformedBinding<S, T>: BindingType, InternalBindingType {

  // MARK: - InternalBindingType

  func _removeRegisteredObservation(_ observation: BindingObservation) {
    implementation.removeRegisteredObservation(observation)
  }

  // MARK: - BindingType

  /// Use lazy variable to avoid setting initial value unnecessarily.
  private var lazyValue: T?

  private(set) var value: T {
    get {
      if let lazyValue {
        return lazyValue
      } else {
        let newValue = getInitialValue()
        lazyValue = newValue
        return newValue
      }
    }
    set {
      lazyValue = newValue
      implementation.invoke(with: newValue)
    }
  }

  var publisher: AnyPublisher<T, Never> {
    implementation.publisher
      .handleEvents(receiveSubscription: { [weak self] _ in
        self?.subscribeUpstream() // only start the observation when the transformed binding is observed
      })
      .eraseToAnyPublisher()
  }

  func observe(_ block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    let observation = implementation.observe(binding: self, block: block)
    subscribeUpstream() // only start the observation when the transformed binding is observed
    return observation
  }

  func observe(_ block: @escaping (_ value: T) -> Void) -> BindingObservation {
    let observation = implementation.observe(binding: self, block: block)
    subscribeUpstream() // only start the observation when the transformed binding is observed
    return observation
  }

  // MARK: - Private

  //                             ┌───────────────────┐
  //     ┌────────────────────── │ Upstream Binding  │
  //     │  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─▶ │    Observation    │
  //     │                       └───────────────────┘
  //     │  │                              ▲  │
  //     │                                 │
  //     │  │                              │  │
  //     │                           stores│
  //     ▼  │                              │  ▼
  // ┌─────────────┐                ┌─────────────┐
  // │             │                │             │
  // │  Upstream   │    retains     │ Transformed │
  // │   Binding   │◀───────────────│   Binding   │
  // │             │                │             │
  // └─────────────┘                └─────────────┘

  private let upstreamBinding: any BindingType<S>
  private let transformer: any TransformerType<S, T>

  private lazy var implementation = BindingImplementation<T>(binding: self)

  private let getInitialValue: () -> T

  private var upstreamBindingObservation: BindingObservation?

  init(upstreamBinding: some BindingType<S>, transformer: some TransformerType<S, T>) {
    self.upstreamBinding = upstreamBinding
    self.transformer = transformer
    self.getInitialValue = { transformer.initialValue(for: upstreamBinding.value) }
  }

  private func subscribeUpstream() {
    guard upstreamBindingObservation == nil else {
      // to avoid duplicated observations
      return
    }

    upstreamBindingObservation = upstreamBinding
      .observe { [weak self] value in
        self?.transformer.upstreamValueChanged(
          newUpstreamValue: value,
          setTransformedValue: { [weak self] transformedValue in
            guard let self = self else {
              /// it's expected that self can be deallocated
              /// for example, for a `delay` binding, the `setTransformedValue` can be called later,
              /// when it's called, self and its upstream maybe deallocated
              return
            }
            self.value = transformedValue
          }
        )
      }
  }
}
