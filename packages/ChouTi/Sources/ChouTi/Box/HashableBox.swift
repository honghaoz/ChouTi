//
//  HashableBox.swift
//
//  Created by Honghao Zhang on 1/2/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public typealias EquatableBox = HashableBox

/// A wrapper box that can hold any value and adds `Hashable (Equatable)` capability.
///
/// This box is useful to add a `Hashable` capability to non-`Hashable` things like blocks. So that you can use the `key` to identify the value.
/// This box is useful comparing non-`Equatable` things like blocks.
public final class HashableBox<Key: Hashable, T>: Hashable {

  /// Make an identified box with key.
  /// - Parameters:
  ///   - key: The identifying key.
  ///   - value: The wrapped value.
  /// - Returns: A new box.
  public static func key(_ key: Key, _ value: T) -> HashableBox<Key, T> {
    HashableBox(key: key, value)
  }

  /// The identifying key.
  ///
  /// - The key is used to identify the value.
  /// - The key is also used as the comparing key for `Equatable`.
  public let key: Key

  /// The wrapped value.
  public let value: T

  /// - Parameters:
  ///   - key: The hashing key. The key is also used as the comparing key for `Equatable`.
  ///   - item: Something that will be unique by id
  public init(key: Key, _ value: T) {
    self.key = key
    self.value = value
  }

  // MARK: - Hashable

  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
  }

  // MARK: - Equatable

  public static func == (lhs: HashableBox<Key, T>, rhs: HashableBox<Key, T>) -> Bool {
    lhs.key == rhs.key
  }
}

public extension HashableBox where Key == MachTimeId {

  /// Make a unique box with unique id in the same app run.
  ///
  /// A unique box is always not equal to any other boxes.
  /// The key is a unique within the same app run.
  ///
  /// - Parameter value: The wrapped value.
  /// - Returns: A new box.
  static func unique(_ value: T) -> HashableBox<MachTimeId, T> {
    HashableBox(key: .id(), value)
  }
}

public extension HashableBox where Key == String {

  /// Make a unique box with unique id (UUID).
  ///
  /// A unique box is always not equal to any other boxes.
  ///
  /// - Parameter value: The wrapped value.
  /// - Returns: A new box.
  static func unique(_ value: T) -> HashableBox<String, T> {
    HashableBox(key: UUID().uuidString, value)
  }
}

public extension HashableBox where Key == AnyHashable {

  /// Make a fixed box.
  ///
  /// All fixed boxes are equal and hash to the same value.
  ///
  /// - Parameter value: The wrapped value.
  /// - Returns: A new box.
  static func fixed(_ value: T) -> HashableBox<AnyHashable, T> {
    HashableBox<AnyHashable, T>(key: 0, value)
  }

  /// Make a unique box with unique id in the same app run.
  ///
  /// A unique box is always not equal to any other boxes.
  /// The key is a unique within the same app run.
  ///
  /// - Parameter value: The wrapped value.
  /// - Returns: A new box.
  static func unique(_ value: T) -> HashableBox<AnyHashable, T> {
    HashableBox(key: MachTimeId.id(), value)
  }
}
