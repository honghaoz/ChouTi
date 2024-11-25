//
//  BindingObservation.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/9/23.
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

/// A binding observation token.
///
/// The observation strongly retains the upstream binding object.
public protocol BindingObservation: AnyObject {

  /// Cancel the observation.
  func cancel()

  /// Store the observation in an observation storage.
  ///
  /// - Parameter storage: A binding observation storage.
  func store(in storage: BindingObservationStorage)

  /// Store the observation in an observation storage with an explicit key.
  ///
  /// - Parameter storage: A binding observation storage.
  /// - Parameter key: A key to store the observation in the storage.
  func store(in storage: BindingObservationStorage, for key: AnyHashable)

  /// A flag indicate if the observation is paused.
  ///
  /// When an observation is paused, no observation block will be called.
  var isPaused: Bool { get }

  /// Pause the observation.
  func pause()

  /// Resume the observation.
  func resume()
}

public extension BindingObservation {

  /// Store the observation in a `BindingObservationStorageProviding` object.
  ///
  /// - Parameter provider: A binding observation storage provider.
  @inlinable
  @inline(__always)
  func store(in provider: some BindingObservationStorageProviding) {
    store(in: provider.bindingObservationStorage)
  }
}

// MARK: - Private

//
//    Observation retained by BindingObservationStorage
//
//
//
//                    upstream binding
//           ┌───────────────────────────────┐
//           │                               │
//           │                               │
//           ▼                               │
//    ┌─────────────┐               ┌────────┴────────┐
//    │             │               │                 │
//    │   Binding   │─ ─ ─ ─ ─ ─ ─ ▶│   Observation   │
//    │             │     weak      │                 │
//    └─────────────┘  (registered  └─────────────────┘
//           ▲        observations)          ▲
//           │                               │
//           │                               │
//           │                               │
//    ┌─────────────┐               ┌─────────────────┐
//    │   Binding   │               │   Observation   │
//    │   Storage   │               │     Storage     │
//    └─────────────┘               └─────────────────┘
//
//
//     * If observation cancels:
//       1. it cleans the binding's registered observation
//       2. it removes self from the observation storage
//       3. then it releases
//
//     * If observation releases:
//       1. it cleans the binding's registered observation
//

final class PrivateBindingObservation<T>: BindingObservation {

  private var upstreamBinding: (any BindingType<T>)!
  private var upstreamBindingAsInternalBindingType: InternalBindingType!

  private var block: ((_ value: T) -> Void)!

  /// tracking the containing storage weakly, so that when `cancel()` is called, the containing storage can remove the observation.
  private var containingStorage: [ObjectIdentifier: WeakBox<BindingObservationStorage>] = [:]

  init(upstreamBinding: some BindingType<T> & InternalBindingType, block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) {
    self.upstreamBinding = upstreamBinding
    self.upstreamBindingAsInternalBindingType = upstreamBinding

    let cancel: BlockVoid = { [weak self] in
      self?.cancel()
    }

    self.block = { value in
      block(value, cancel)
    }
  }

  deinit {
    upstreamBindingAsInternalBindingType?._removeRegisteredObservation(self)
    // why don't clean up containingStorage?
    // because if self is released, the containingStorage must be already removed.
  }

  func invoke(with value: T) {
    guard !isPaused else {
      return
    }
    block(value)
  }

  // MARK: - BindingObservation

  func cancel() {
    upstreamBindingAsInternalBindingType?._removeRegisteredObservation(self)

    containingStorage.values.forEach {
      $0.object?.remove(self)
    }
    containingStorage.removeAll()

    // release upstream
    upstreamBinding = nil
    upstreamBindingAsInternalBindingType = nil
  }

  func store(in storage: BindingObservationStorage) {
    storage._store(self, key: nil)
    containingStorage[ObjectIdentifier(storage)] = WeakBox(storage)
  }

  func store(in storage: BindingObservationStorage, for key: AnyHashable) {
    storage._store(self, key: key)
    containingStorage[ObjectIdentifier(storage)] = WeakBox(storage)
  }

  private(set) var isPaused: Bool = false

  func pause() {
    isPaused = true
  }

  func resume() {
    isPaused = false
  }
}

final class AggregatedBindingObservation: BindingObservation {

  private let observations: [BindingObservation]

  init(observations: [BindingObservation]) {
    ChouTi.assert(!observations.isEmpty, "AggregatedBindingObservation must have at least one observation.")
    self.observations = observations
  }

  // MARK: - BindingObservation

  func cancel() {
    observations.forEach { $0.cancel() }
  }

  func store(in storage: BindingObservationStorage) {
    observations.forEach { $0.store(in: storage) }
  }

  func store(in storage: BindingObservationStorage, for key: AnyHashable) {
    observations.forEach { $0.store(in: storage, for: key) }
  }

  var isPaused: Bool { observations.first?.isPaused ?? false }

  func pause() {
    observations.forEach { $0.pause() }
  }

  func resume() {
    observations.forEach { $0.resume() }
  }
}
