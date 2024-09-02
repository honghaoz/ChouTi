//
//  Dictionary+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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

// MARK: - Merge

public extension Dictionary {

  /// Merges the given dictionary into this dictionary.
  ///
  /// - Parameter another: The dictionary to merge into this dictionary.
  /// - Complexity: O(n), where n is the number of key-value pairs in `another`.
  /// - Note: If a key exists in both dictionaries, the value from `another` will be used.
  mutating func merge(_ another: [Key: Value]) {
    self.merge(another) { _, new in new }
  }

  /// Creates a new dictionary by merging this dictionary with another.
  ///
  /// - Parameter another: The dictionary to merge with this dictionary.
  /// - Returns: A new dictionary containing all key-value pairs from both dictionaries.
  /// - Complexity: O(n), where n is the combined number of key-value pairs in both dictionaries.
  /// - Note: If a key exists in both dictionaries, the value from `another` will be used.
  func merging(_ another: [Key: Value]) -> [Key: Value] {
    self.merging(another) { _, new in new }
  }

  /// Merges two dictionaries, with the right dictionary taking precedence.
  ///
  /// - Parameters:
  ///   - left: The base dictionary.
  ///   - right: The dictionary to merge into the base. If `nil`, only the left dictionary is returned.
  /// - Returns: A new dictionary containing all key-value pairs from both dictionaries.
  /// - Complexity: O(n), where n is the number of key-value pairs in `right`.
  /// - Note: If a key exists in both dictionaries, the value from `right` will be used.
  static func + (left: [Key: Value], right: [Key: Value]?) -> [Key: Value] {
    guard let right else {
      return left
    }
    return left.merging(right)
  }

  /// Merges the right dictionary into the left dictionary.
  ///
  /// - Parameters:
  ///   - left: The dictionary to be updated.
  ///   - right: The dictionary to merge from. If `nil`, `left` remains unchanged.
  /// - Complexity: O(n), where n is the number of key-value pairs in `right`.
  /// - Note: If a key exists in both dictionaries, the value from `right` will be used.
  static func += (left: inout [Key: Value], right: [Key: Value]?) {
    guard let right else {
      return
    }
    left.merge(right)
  }
}

// MARK: - Random Subset

public extension Dictionary {

  /// Returns a random subset of the dictionary.
  ///
  /// - Complexity: O(n), where n is the number of key-value pairs in the dictionary.
  /// - Returns: A new dictionary containing a random subset of the original key-value pairs.
  func randomSubset() -> [Key: Value] {
    var result: [Key: Value] = [:]
    for (key, value) in self {
      if Bool.random() {
        result[key] = value
      }
    }
    return result
  }
}

// MARK: - Convenient

public extension Dictionary {

  /// Returns `true` if the key is in the dictionary.
  ///
  /// - Parameter key: The key to check for.
  /// - Returns: `true` if the key exists, `false` otherwise.
  /// - Complexity: O(1) on average, worst case O(n) where n is the number of elements.
  @inlinable
  @inline(__always)
  func hasKey(_ key: Key) -> Bool {
    self[key] != nil
  }

  /// Returns `true` if the key is NOT in the dictionary.
  ///
  /// - Parameter key: The key to check for.
  /// - Returns: `true` if the key does not exist, `false` otherwise.
  /// - Complexity: O(1) on average, worst case O(n) where n is the number of elements.
  @inlinable
  @inline(__always)
  func hasNoKey(_ key: Key) -> Bool {
    self[key] == nil
  }
}

// MARK: - Get Key for Value

public extension Dictionary where Value: Equatable {

  /// Get first key for provided value.
  ///
  /// - Parameter value: The value to search for.
  /// - Returns: The first key found that maps to the given value, or `nil` if no such key exists.
  /// - Complexity: O(n) in the worst case, where n is the number of key-value pairs in the dictionary.
  /// - Warning: If multiple keys map to the same value, the returned key is arbitrary.
  subscript(firstKeyFor value: Value) -> Key? {
    first { $0.value == value }?.key
  }

  /// Get all keys for provided value.
  ///
  /// - Parameter value: The value to search for.
  /// - Returns: An array of all keys that map to the given value.
  /// - Complexity: O(n), where n is the number of key-value pairs in the dictionary.
  /// - Note: If multiple keys map to the same value, all keys are returned.
  func allKeys(for value: Value) -> [Key] {
    compactMap { $0.value == value ? $0.key : nil }
  }

  /// https://stackoverflow.com/a/48821509/3164091
}
