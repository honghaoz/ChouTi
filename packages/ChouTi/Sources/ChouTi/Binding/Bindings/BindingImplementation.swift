//
//  BindingImplementation.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/1/23.
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

/// The shared binding type implementation.
final class BindingImplementation<T> {

  lazy var publisher: AnyPublisher<T, Never> = subject.eraseToAnyPublisher()

  // swiftlint:disable:next force_unwrapping
  private lazy var subject = CurrentValueSubject<T, Never>(binding!.value)

  /// For notifying.
  private lazy var registeredObservations: OrderedDictionary<ObjectIdentifier, WeakBox<PrivateBindingObservation<T>>> = [:]

  private weak var binding: (any BindingType<T>)!

  init(binding: some BindingType<T>) {
    self.binding = binding
  }

  func observe(binding: some BindingType<T> & InternalBindingType, block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    let observation = PrivateBindingObservation(upstreamBinding: binding, block: block)
    registeredObservations[ObjectIdentifier(observation)] = WeakBox(observation)
    return observation
  }

  func observe(binding: some BindingType<T> & InternalBindingType, block: @escaping (T) -> Void) -> BindingObservation {
    let observation = PrivateBindingObservation(upstreamBinding: binding, block: { value, _ in block(value) })
    registeredObservations[ObjectIdentifier(observation)] = WeakBox(observation)
    return observation
  }

  func invoke(with value: T) {
    registeredObservations.values.forEach { box in
      box.object.assert()?.invoke(with: value)
    }

    subject.send(value)
  }

  func removeRegisteredObservation(_ observation: BindingObservation) {
    registeredObservations.removeValue(forKey: ObjectIdentifier(observation))
  }
}
