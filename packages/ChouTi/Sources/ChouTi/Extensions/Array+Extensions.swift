//
//  Array+Extensions.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension Array where Element: Hashable {

  /// Get a new array with no duplicates while still maintaining the original order.
  /// - Returns: A new array with no duplicates.
  func removingDuplicates() -> Self {
    var seen: Set<Element> = []
    return filter {
      if seen.contains($0) {
        return false
      }
      seen.insert($0)
      return true
    }
  }

  /// Remove duplicated elements.
  mutating func removeDuplicates() {
    self = removingDuplicates()
  }

  /// Check if all elements are unique.
  /// - Returns: `true` if all elements are unique.
  func allUnique() -> Bool {
    var seen: Set<Element> = []
    for element in self {
      if seen.contains(element) {
        return false
      }
      seen.insert(element)
    }
    return true
  }

  /// Convert an array to a set.
  /// - Returns: A set.
  @inlinable
  @inline(__always)
  func asSet() -> Set<Element> {
    Set(self)
  }
}

public extension Array where Element: Equatable {

  /// Returns a boolean value of whether all elements in the array are equal.
  /// - Returns: `true` if all elements are equal or is an empty array.
  func allEqual() -> Bool {
    /// From: https://stackoverflow.com/a/50806159/3164091
    guard let last else {
      return true
    }
    return dropLast().allSatisfy { $0 == last }
  }

  /// Returns a new array with the first specified element removed.
  /// - Parameter element: The element to remove. Only the first equal element is removed.
  /// - Returns: A new array.
  func removingFirstElement(_ element: Element) -> Self {
    var new = self
    if let index = new.firstIndex(of: element) {
      new.remove(at: index)
    }
    return new
  }

  /// Removes the first specified element from the array.
  /// - Parameter element: The element to remove. Only the first equal element is removed.
  mutating func removeFirstElement(_ element: Element) {
    if let index = firstIndex(of: element) {
      remove(at: index)
    }
  }
}

public extension Array {

  /// Returns the first element of the specified type in the array.
  ///
  /// Example:
  /// ```swift
  /// let items: [Any] = [1, "String", 3.14, ["Array"]]
  /// let stringValue: String? = items.first(type: String.self)
  /// print(stringValue) // Outputs: "String"
  /// ```
  ///
  /// - Parameter type: The type of element you are looking for.
  /// - Returns: The first element of the specified type, or `nil` if an element with that type doesn't exist in the array.
  @inlinable
  @inline(__always)
  func first<T>(type: T.Type) -> T? {
    first(where: { $0 is T }) as? T
  }

  /// Returns the last element of the specified type in the array.
  ///
  /// Example:
  /// ```swift
  /// let items: [Any] = [1, "String", 3.14, ["Array"]]
  /// let stringValue: String? = items.last(type: String.self)
  /// print(stringValue) // Outputs: "String"
  /// ```
  ///
  /// - Parameter type: The type of element you are looking for.
  /// - Returns: The last element of the specified type, or `nil` if an element with that type doesn't exist in the array.
  @inlinable
  @inline(__always)
  func last<T>(type: T.Type) -> T? {
    last(where: { $0 is T }) as? T
  }

  /// Removes and returns the first element of the array.
  ///
  /// - Returns: The first element of the array if the array is not empty; otherwise, `nil`.
  mutating func popFirst() -> Element? {
    guard !isEmpty else {
      return nil
    }
    return removeFirst()
  }

  /// Remove `nil` values and return a non-optional array.
  @inlinable
  @inline(__always)
  func compacted<T>() -> [T] where Element == T? {
    /// https://stackoverflow.com/questions/54605747/array-extension-where-element-is-optional-and-the-the-return-type-is-wrapped
    /// https://stackoverflow.com/a/54261472/3164091
    compactMap { $0 }
  }

  /// Splits this array into a list of groups, each not exceeding the given size.
  ///
  /// Example:
  /// ```swift
  /// let array = [1, 2, 3, 4, 5, 6, 7]
  /// array.chunked(2, acceptPartialResult: true) => [[1, 2], [3, 4], [5, 6], [7]]
  /// ```
  ///
  /// - Parameters:
  ///   - size: The size of each group. Must be greater than 1 and can be greater than the number of elements in this collection.
  ///   - acceptPartialResult: If `true`, the last group may have fewer elements than the given size.
  /// - Returns: An array of groups.
  func chunked(_ size: Int, acceptPartialResult: Bool = false) -> [[Element]] {
    guard !isEmpty else {
      return []
    }
    guard size > 0 else {
      return []
    }
    if size == 1 {
      return map { [$0] }
    }

    var result: [[Element]] = []
    result.reserveCapacity((count + size - 1) / size) // pre-allocate memory for efficiency

    var i = 0
    while i < count {
      let endIndex = index(i, offsetBy: size, limitedBy: endIndex) ?? endIndex
      result.append(Array(self[i ..< endIndex]))
      i = endIndex
    }

    if !acceptPartialResult, let lastGroup = result.last, lastGroup.count < size {
      result.removeLast()
    }

    return result
  }

  /// Splits this array into a list of pairs. If the number of elements is odd, the last element is ignored.
  ///
  /// Example:
  /// ```swift
  /// let array = [1, 2, 3, 4, 5, 6, 7]
  /// array.asPairs() => [(1, 2), (3, 4), (5, 6)]
  /// ```
  ///
  /// - Returns: An array of pairs.
  func asPairs() -> [(Element, Element)] {
    chunked(2, acceptPartialResult: false).map { ($0[0], $0[1]) }
  }
}

public extension Array {

  /// Returns a sequence of pairs (index, element) for each element in the array.
  ///
  /// Example:
  /// ```swift
  /// let fruits = ["apple", "banana", "cherry"]
  /// for (index, fruit) in fruits.indexed() {
  ///     print("\(index): \(fruit)")
  /// }
  /// // Outputs:
  /// // 0: apple
  /// // 1: banana
  /// // 2: cherry
  /// ```
  ///
  /// - Returns: A `Zip2Sequence` sequence of pairs (index, element) for each element in the array.
  @inlinable
  @inline(__always)
  func indexed() -> Zip2Sequence<PartialRangeFrom<Int>, Self> {
    /// https://twitter.com/natpanferova/status/1528991072277237761
    /// https://khanlou.com/2017/03/you-probably-don't-want-enumerated/
    /// https://github.com/apple/swift-algorithms/blob/main/Guides/Indexed.md
    zip(0..., self)
  }
}
