//
//  OrderedDictionary.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An ordered dictionary.
public struct OrderedDictionary<KeyType: Hashable, ValueType> {

  /// The number of key-value pairs in the dictionary.
  ///
  /// Time complexity: O(1)
  public var count: Int { keys.count }

  /// Get the first value.
  ///
  /// - Note: This is faster than `values.first`.
  ///
  /// Time complexity: O(1)
  public var firstValue: ValueType? {
    guard let firstKey = keys.first else {
      return nil
    }
    return dictionary[firstKey]
  }

  /// Get the last value.
  ///
  /// - Note: This is faster than `values.last`.
  ///
  /// Time complexity: O(1)
  public var lastValue: ValueType? {
    guard let lastKey = keys.last else {
      return nil
    }
    return dictionary[lastKey]
  }

  /// Get ordered values.
  ///
  /// Time complexity: O(n)
  public var values: [ValueType] {
    var result = [ValueType]()
    result.reserveCapacity(keys.count)
    for key in keys {
      // swiftlint:disable:next force_unwrapping
      result.append(dictionary[key]!)
    }
    return result
  }

  /// Get ordered keys.
  ///
  /// Time complexity: O(1)
  public private(set) var keys: [KeyType]

  /// The storage dictionary.
  fileprivate var dictionary: [KeyType: ValueType]

  /// Create an empty ordered dictionary.
  public init() {
    keys = []
    dictionary = [:]
  }

  /// Create an ordered dictionary with keys and values.
  ///
  /// - Note: The keys must be unique. If the keys are not unique, the initializer will return `nil`.
  /// - Note: The keys and values must have the same count. If the counts are not the same, the initializer will return `nil`.
  ///
  /// - Parameters:
  ///   - keys: The keys for the new dictionary. The keys must be unique.
  ///   - values: The values for the new dictionary. The values must have the same count as the keys.
  public init?(keys: [KeyType], values: [ValueType]) {
    guard keys.count == values.count, keys.allUnique() else {
      return nil
    }

    self.keys = keys

    dictionary = [KeyType: ValueType](minimumCapacity: keys.count)
    for i in 0 ..< keys.count {
      dictionary[keys[i]] = values[i]
    }
  }

  /// Get/Set the value for the key.
  ///
  /// - If the key is in the dictionary, the setter will update the value.
  /// - If the key is not in the dictionary, the setter will append the key.
  /// - If the value is `nil`, the setter will remove the key.
  ///
  /// Time complexity: O(1)
  public subscript(key: KeyType) -> ValueType? {
    get {
      dictionary[key]
    }

    set {
      if newValue == nil {
        // remove key
        removeValue(forKey: key)
      } else {
        // if this is a new key, append the key
        if dictionary[key] == nil {
          keys.append(key)
        }
        dictionary[key] = newValue
      }
    }
  }

  /// Get the value for the index.
  ///
  /// - Warning: The index must be within the bounds. Otherwise, the app will crash.
  ///
  /// Time complexity: O(1)
  public subscript(index: Int) -> (KeyType, ValueType) {
    precondition(index >= 0 && index < keys.count, "index out of bounds")

    let key = keys[index]
    // swiftlint:disable:next force_unwrapping
    let value = dictionary[key]!

    return (key, value)
  }

  /// Append a key-value pair to the dictionary.
  /// - Parameters:
  ///   - value: The value for the key to append.
  ///   - key: The key to append.
  @inlinable
  @inline(__always)
  public mutating func append(value: ValueType, forKey key: KeyType) {
    insert(value: value, forKey: key, atIndex: count)
  }

  /// Remove and return the last key-value pair.
  /// - Returns: The key-value pair that was removed or `nil` if the dictionary is empty.
  @discardableResult
  public mutating func popLast() -> ValueType? {
    guard let key = keys.popLast() else {
      return nil
    }
    return dictionary.removeValue(forKey: key)
  }

  /// Remove and return the value for the key.
  /// - Parameter key: The key to remove.
  /// - Returns: The value that was removed or `nil` if the key is not in the dictionary.
  @discardableResult
  public mutating func removeValue(forKey key: KeyType) -> ValueType? {
    if let index = keys.firstIndex(of: key) {
      keys.remove(at: index)
    }
    return dictionary.removeValue(forKey: key)
  }

  /// Remove all values from the dictionary.
  /// - Parameter keepingCapacity: Whether the dictionary should keep its underlying buffer.
  public mutating func removeAll(keepingCapacity: Bool = false) {
    keys.removeAll(keepingCapacity: keepingCapacity)
    dictionary.removeAll(keepingCapacity: keepingCapacity)
  }

  /// Check if the key is in the dictionary.
  /// - Parameter key: The key to check.
  /// - Returns: `true` if the key is in the dictionary.
  public func hasKey(_ key: Key) -> Bool {
    dictionary[key] != nil
  }

  /// Check if the key is not in the dictionary.
  /// - Parameter key: The key to check.
  /// - Returns: `true` if the key is not in the dictionary.
  public func hasNoKey(_ key: Key) -> Bool {
    dictionary[key] == nil
  }

  /// Reserve enough space to store the specified number of values.
  /// - Parameter minimumCapacity: The minimum number of key-value pairs that the dictionary should be able to store.
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    keys.reserveCapacity(minimumCapacity)
    dictionary.reserveCapacity(minimumCapacity)
  }
}

public extension OrderedDictionary {

  /// Insert a key-value pair at the specified position.
  ///
  /// - Warning: The index must be within `[0...count]`. Otherwise, the app will crash.
  ///
  /// - Parameters:
  ///   - value: The value to insert.
  ///   - key: The key to insert.
  ///   - index: The position to insert the key-value pair.
  /// - Returns: The value that was replaced, or `nil` if a new key-value pair was inserted.
  @discardableResult
  mutating func insert(value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType? {
    precondition(index >= 0 && index <= keys.count, "index out of bounds")

    var adjustedIndex = index

    // If insert for key: b, at index 2
    //
    //        |
    //        v
    //   0    1    2
    // ["a", "b", "c"]
    //
    // Remove "b"
    //   0    1
    // ["a", "c"]

    let existingValue = dictionary[key]
    if existingValue != nil {
      // swiftlint:disable:next force_unwrapping
      let existingIndex = keys.firstIndex(of: key)!
      if existingIndex < index, index >= keys.count {
        adjustedIndex -= 1
      }

      keys.remove(at: existingIndex)
    }
    keys.insert(key, at: adjustedIndex)
    dictionary[key] = value

    return existingValue
  }

  /// Remove and return the key-value pair at the specified position.
  ///
  /// - Warning: The index must be within the bounds. Otherwise, the app will crash.
  ///
  /// - Parameter index: The position of the key-value pair to remove.
  /// - Returns: The key-value pair that was removed.
  @discardableResult
  mutating func remove(at index: Int) -> (KeyType, ValueType) {
    precondition(index < keys.count, "index out of bounds")

    let key = keys.remove(at: index)
    let value = dictionary.removeValue(forKey: key)

    // swiftlint:disable:next force_unwrapping
    return (key, value!)
  }
}

// MARK: - Collection

extension OrderedDictionary: Collection {

  @inlinable
  @inline(__always)
  public var startIndex: Int {
    keys.startIndex
  }

  @inlinable
  @inline(__always)
  public var endIndex: Int {
    keys.endIndex
  }

  @inlinable
  @inline(__always)
  public func index(after i: Int) -> Int {
    keys.index(after: i)
  }
}

// MARK: - ExpressibleByDictionaryLiteral

extension OrderedDictionary: ExpressibleByDictionaryLiteral {

  /// https://www.vadimbulavin.com/initialization-with-literals/
  public init(dictionaryLiteral elements: (KeyType, ValueType)...) {
    keys = [KeyType]()
    keys.reserveCapacity(elements.count)

    dictionary = [KeyType: ValueType](minimumCapacity: elements.count)

    for (key, value) in elements {
      keys.append(key)
      dictionary[key] = value
    }
  }
}

// MARK: - Sequence

extension OrderedDictionary: Sequence {

  public func makeIterator() -> Iterator {
    Iterator(
      keys: keys.makeIterator(),
      values: values.makeIterator()
    )
  }

  public struct Iterator: IteratorProtocol {

    private var index = 0

    private var keys: IndexingIterator<[KeyType]>
    private var values: IndexingIterator<[Value]>

    init(keys: IndexingIterator<[KeyType]>, values: IndexingIterator<[Value]>) {
      self.keys = keys
      self.values = values
    }

    public mutating func next() -> (KeyType, ValueType)? {
      if let key = keys.next() {
        guard let value = values.next() else {
          #if DEBUG
          ChouTi.assertFailure("keys and values count must match")
          #endif
          return nil
        }
        return (key, value)
      } else {
        return nil
      }
    }
  }
}

// MARK: - Equatable

extension OrderedDictionary: Equatable where Value: Equatable {

  public static func == (lhs: OrderedDictionary, rhs: OrderedDictionary) -> Bool {
    lhs.keys == rhs.keys && lhs.values == rhs.values
  }
}

// MARK: - Hashable

extension OrderedDictionary: Hashable where Value: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(keys)
    hasher.combine(values)
  }
}

// MARK: - Find Keys

public extension OrderedDictionary where Value: Equatable {

  /// Get first key for provided value.
  ///
  /// ⚠️ The dictionary should contains unique key for value, otherwise, the returned key can vary.
  subscript(firstKeyFor value: Value) -> Key? {
    dictionary.first { $0.value == value }?.key
  }

  /// Get all keys for provided value.
  func allKeys(for value: Value) -> [Key] {
    dictionary.compactMap { $0.value == value ? $0.key : nil }
  }
}

public extension OrderedDictionary {

  /// Get first key for provided value evaluation block.
  ///
  /// Example: `self.viewStore.removingViews[firstKeyFor: { $0.id == newViewItem.id }]`
  subscript(firstKeyWhere value: (Value) -> Bool) -> Key? {
    dictionary.first { value($0.value) }?.key
  }

  /// Get all keys for provided value evaluation block.
  ///
  /// Example: `viewStore.removingViews.allKeys(for: { $0.id == newViewItem.id })`
  func allKeys(where value: (Value) -> Bool) -> [Key] {
    dictionary.compactMap { value($0.value) ? $0.key : nil }
  }
}
