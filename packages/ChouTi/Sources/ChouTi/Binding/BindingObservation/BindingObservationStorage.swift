//
//  BindingObservationStorage.swift
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

/// A storage to hold binding observations.
public final class BindingObservationStorage {

  /// A shared binding observation storage.
  public static let shared = BindingObservationStorage()

  private lazy var observations: [AnyHashable: BindingObservation] = [:]

  /// Initialize a binding observation storage.
  public init() {}

  /// Stores an observation.
  ///
  /// - Parameter observation: The observation to keep.
  public func store(_ observation: BindingObservation) {
    observation.store(in: self) // let `PrivateBindingObservation` to track the containing storage
  }

  /// Stores the observation with an explicit key.
  ///
  /// - Parameters:
  ///   - observation: The observation to store.
  ///   - key: The observation key.
  public func store(_ observation: BindingObservation, for key: AnyHashable) {
    observation.store(in: self, for: key) // let `PrivateBindingObservation` to track the containing storage
  }

  /// Check if the storage already stores the specified observation.
  ///
  /// - Parameter observation: The observation to check.
  /// - Returns: Returns `true` if the observation is stored in the storage.
  public func contains(_ observation: BindingObservation) -> Bool {
    observations.hasKey(ObjectIdentifier(observation))
  }

  /// Get the observation for a key.
  ///
  /// - Parameter key: The observation key.
  /// - Returns: A valid `BindingObservation` instance if found.
  public func observation(for key: AnyHashable) -> BindingObservation? {
    observations[key]
  }

  /// Remove the observation from the storage.
  ///
  /// - Parameter observation: The observation to remove.
  public func remove(_ observation: BindingObservation) {
    observations.removeValue(forKey: ObjectIdentifier(observation))
  }

  /// Remove the observation with the specified key.
  ///
  /// - Parameter key: The key for the observation to remove.
  /// - Returns: A removed observation if found.
  @discardableResult
  public func remove(for key: AnyHashable) -> BindingObservation? {
    observations.removeValue(forKey: key)
  }

  /// Remove all observations.
  public func removeAll() {
    observations.removeAll()
  }

  /// Called from `PrivateBindingObservation`.
  func _store(_ observation: BindingObservation, key: AnyHashable?) {
    if let key {
      observations[key] = observation
    } else {
      observations[ObjectIdentifier(observation)] = observation
    }
  }
}
