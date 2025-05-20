//
//  BindingStorage.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/15/22.
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

/// A storage to hold bindings.
public final class BindingStorage {

  /// A shared binding storage.
  public static let shared = BindingStorage()

  private lazy var bindings: [AnyHashable: any BindingType] = [:]

  public init() {}

  /// Stores a binding into the storage.
  /// - Parameter binding: The binding to store.
  public func store(_ binding: some BindingType) {
    bindings[ObjectIdentifier(binding)] = binding
  }

  /// Check if a binding is stored in the storage.
  /// - Parameter binding: The binding to check.
  /// - Returns: Returns `true` if the binding is stored in the storage.
  public func contains(_ binding: some BindingType) -> Bool {
    bindings.hasKey(ObjectIdentifier(binding))
  }

  /// Remove the binding with the key.
  /// - Parameters:
  ///   - binding: The binding to remove.
  ///   - assertIfNotExists: If should assert if such binding doesn't exist.
  public func remove(_ binding: some BindingType, assertIfNotExists: Bool = true) {
    let key = ObjectIdentifier(binding)
    if assertIfNotExists {
      ChouTi.assert(bindings[key] != nil, "remove non-existent binding: \(binding)")
    }
    bindings.removeValue(forKey: key)
  }

  /// Stores the binding with an explicit key.
  /// - Parameters:
  ///   - binding: The binding to store.
  ///   - key: The key for the binding.
  public func store(_ binding: some BindingType, for key: AnyHashable) {
    bindings[key] = binding
  }

  /// Get the binding for a key.
  /// - Parameter key: The key to query.
  /// - Returns: A valid `BindingType` instance if found.
  public func binding(for key: AnyHashable) -> (any BindingType)? {
    bindings[key]
  }

  /// Remove the binding with the specified key.
  /// - Parameter key: The key for the binding to remove.
  /// - Returns: A removed binding if found.
  @discardableResult
  public func remove(for key: AnyHashable) -> (any BindingType)? {
    bindings.removeValue(forKey: key)
  }

  /// Remove all bindings.
  public func removeAll() {
    bindings.removeAll()
  }
}
