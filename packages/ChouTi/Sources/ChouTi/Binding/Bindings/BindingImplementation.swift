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

  private(set) lazy var publisher: AnyPublisher<T, Never> = subject.eraseToAnyPublisher()

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
    guard let binding else {
      return
    }

    guard BindingLoopDetector.enter(binding: binding) else {
      if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
        ChouTi.assertFailure("Binding loop detected.", metadata: ["binding": "\(binding)"])
      } else {
        ChouTi.assertFailure("Binding loop detected.")
      }
      return
    }
    defer {
      BindingLoopDetector.leave(binding: binding)
    }

    registeredObservations.values.forEach { box in
      box.object.assert()?.invoke(with: value)
    }

    subject.send(value)
  }

  func removeRegisteredObservation(_ observation: BindingObservation) {
    registeredObservations.removeValue(forKey: ObjectIdentifier(observation))
  }
}

// MARK: - Binding Loop Detection

private enum BindingLoopDetector {

  private enum Constants {
    static let threadDictionaryKey = "io.chouti.binding.loop.detector"
  }

  private final class Context {
    var activeBindings: Set<ObjectIdentifier> = []
  }

  static func enter(binding: AnyObject) -> Bool {
    let context = contextForCurrentThread()
    let identifier = ObjectIdentifier(binding)
    guard !context.activeBindings.contains(identifier) else {
      return false
    }
    context.activeBindings.insert(identifier)
    return true
  }

  static func leave(binding: AnyObject) {
    let context = contextForCurrentThread()
    context.activeBindings.remove(ObjectIdentifier(binding))
    if context.activeBindings.isEmpty {
      Thread.current.threadDictionary.removeObject(forKey: Constants.threadDictionaryKey)
    }
  }

  private static func contextForCurrentThread() -> Context {
    let threadDictionary = Thread.current.threadDictionary
    if let context = threadDictionary[Constants.threadDictionaryKey] as? Context {
      return context
    }

    let context = Context()
    threadDictionary[Constants.threadDictionaryKey] = context
    return context
  }
}
