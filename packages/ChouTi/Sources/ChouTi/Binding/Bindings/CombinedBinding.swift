//
//  CombinedBinding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/4/23.
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

final class CombinedBinding<T>: BindingType, InternalBindingType {

  // MARK: - InternalBindingType

  func _removeRegisteredObservation(_ observation: BindingObservation) {
    implementation.removeRegisteredObservation(observation)
  }

  // MARK: - BindingType

  private(set) var value: T {
    get {
      getValue()
    }
    set {
      implementation.invoke(with: newValue)
    }
  }

  var publisher: AnyPublisher<T, Never> {
    implementation.publisher
  }

  func observe(_ block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    implementation.observe(binding: self, block: block)
  }

  func observe(_ block: @escaping (_ value: T) -> Void) -> BindingObservation {
    implementation.observe(binding: self, block: block)
  }

  // MARK: - Private

  private let upstreamBinding1: any BindingType
  private let upstreamBinding2: any BindingType

  private lazy var implementation = BindingImplementation<T>(binding: self)

  private let getValue: () -> T

  private let bindingObservationStorage = BindingObservationStorage()

  // swiftformat:disable:next all
  init<U1, U2>(upstreamBinding1: some BindingType<U1>, upstreamBinding2: some BindingType<U2>) where (U1, U2) == T {
    self.upstreamBinding1 = upstreamBinding1
    self.upstreamBinding2 = upstreamBinding2
    self.getValue = { (upstreamBinding1.value, upstreamBinding2.value) }

    // Memory Diagram:
    //
    //   ┌────────────┐              ┌────────────┐
    //   │            │              │            │
    //   │  Binding1  │◀──┐     ┌───▶│  Binding2  │
    //   │            │   │     │    │            │
    //   └────────────┘   │     │    └────────────┘
    //          ▲         │     │           ▲
    //          │         │     │           │
    //          │         │     │           │
    // ┌────────────────┐ │     │  ┌────────────────┐
    // │                │ │     │  │                │
    // │  Observation1  │ │     │  │  Observation2  │
    // │                │ │     │  │                │
    // └────────────────┘ │     │  └────────────────┘
    //          ▲         │     │           ▲
    //          │         │     │           │
    //          │         │     │           │
    //          │   ┌─────┴─────┴───────┐   │
    //          │   │                   │   │
    //          └───│ Combined Binding  │───┘
    //              │                   │
    //              └───────────────────┘

    let observation1 = upstreamBinding1.observe { [weak upstreamBinding2, weak self] value1 in
      guard let upstreamBinding2, let self else {
        ChouTi.assertFailure("upstreamBinding2 \(upstreamBinding2, default: "nil") or combined binding \(self, default: "nil") is nil, this shouldn't happen")
        return
      }
      self.value = (value1, upstreamBinding2.value)
    }

    let observation2 = upstreamBinding2.observe { [weak upstreamBinding1, weak self] value2 in
      guard let upstreamBinding1, let self else {
        ChouTi.assertFailure("upstreamBinding1 \(upstreamBinding1, default: "nil") or combined binding \(self, default: "nil") is nil, this shouldn't happen")
        return
      }
      self.value = (upstreamBinding1.value, value2)
    }

    bindingObservationStorage.store(observation1)
    bindingObservationStorage.store(observation2)
  }
}
