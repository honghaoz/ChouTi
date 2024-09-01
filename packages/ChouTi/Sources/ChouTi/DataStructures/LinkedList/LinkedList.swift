//
//  LinkedList.swift
//  ChouTi
//
//  Created by Honghao Zhang on 12/30/22.
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

/// A linked list.
///
/// See also `IndexedLinkedList` for a version that supports fast random access.
public final class LinkedList<T>: LinkedListType, CustomStringConvertible {

  public typealias Node = LinkedListNode<T>

  /// The head of the linked list.
  public private(set) var head: Node?

  /// The tail of the linked list.
  public private(set) var tail: Node?

  /// The head of the linked list.
  public var first: Node? { head }

  /// The tail of the linked list.
  public var last: Node? { tail }

  /// Returns `true` if the linked list has no nodes.
  public var isEmpty: Bool { head == nil }

  /// The length of the linked list.
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  public var count: Int {
    guard var node = head else {
      return 0
    }

    var count = 1
    while let next = node.next {
      node = next
      count += 1
    }
    return count
  }

  /// Initializes an empty linked list.
  public init() {}

  /// Initializes a linked list with the given value.
  ///
  /// - Parameter value: The value of the node.
  @inlinable
  @inline(__always)
  public convenience init(_ value: T) {
    self.init([value])
  }

  /// Initializes a linked list with the given array.
  ///
  /// - Parameter array: An array of values.
  public convenience init(_ array: [T]) {
    self.init()
    array.forEach {
      append($0)
    }
  }

  // MARK: - Query

  /// Returns the node at the specific index.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  ///
  /// - Parameter index: The index of the node.
  /// - Returns: The node at the given index.
  public func node(at index: Int) -> Node {
    guard index >= 0 else {
      fatalError("index must be greater or equal to 0")
    }
    guard !isEmpty else {
      fatalError("List is empty")
    }

    // swiftlint:disable:next force_unwrapping
    var node = head!
    for _ in 0 ..< index {
      guard let next = node.next else {
        fatalError("index is out of bounds.")
      }
      node = next
    }

    return node
  }

  /// Returns the node at the specific index.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  ///
  /// - Parameter index: The index of the node.
  /// - Returns: The node at the given index.
  @inlinable
  @inline(__always)
  public subscript(index: Int) -> Node {
    node(at: index)
  }

  /// Returns the index of the specified node, if it exists in the list.
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  ///
  /// - Parameter node: The node to search for.
  /// - Returns: The index of the node, or `nil` if the node is not in the list.
  public func index(of node: Node) -> Int? {
    var currentNode = head
    var currentIndex = 0

    while currentNode != nil {
      if currentNode === node {
        return currentIndex
      }

      currentNode = currentNode?.next
      currentIndex += 1
    }

    return nil
  }

  // MARK: - Append

  /// Append a value to the end of the list.
  ///
  /// - Complexity: O(1)
  ///
  /// - Parameter value: The node value to append.
  @inlinable
  @inline(__always)
  public func append(_ value: T) {
    append(Node(value: value), copy: false)
  }

  /// Append a `LinkedListNode` to the end of the list.
  ///
  /// ⚠️ It is programmer's responsibility to make sure the node is not in the list.
  ///
  /// - Complexity: O(1)
  ///
  /// - Parameters:
  ///   - newNode: The node to append.
  ///   - copy: If the node should be copied. Default is `false`.
  public func append(_ newNode: Node, copy: Bool = false) {
    let newNode = copy ? Node(value: newNode.value) : newNode

    if let lastNode = last {
      newNode.previous = lastNode
      lastNode.next = newNode
      tail = newNode
    } else {
      head = newNode
      tail = newNode
    }
  }

  /// Append a `LinkedList` to the end of the list.
  ///
  /// ⚠️ It is programmer's responsibility to make sure the list is not in the list.
  ///
  /// - Complexity: O(1) if the list is not copied, otherwise O(n).
  ///
  /// - Parameters:
  ///   - list: The list to be appended.
  ///   - copy: If the list should be copied. Default is `false`.
  public func append(_ list: some LinkedListType<T>, copy: Bool = false) {
    if copy {
      var nodeToCopy = list.head
      while let node = nodeToCopy {
        append(node.value)
        nodeToCopy = node.next
      }
    } else {
      if let lastNode = last {
        lastNode.next = list.head
        list.head?.previous = lastNode
        tail = list.tail
      } else {
        head = list.head
        tail = list.tail
      }
    }
  }

  // MARK: - Prepend

  /// Prepend a value to the start of the list.
  ///
  /// - Complexity: O(1)
  ///
  /// - Parameter value: The node value to prepend.
  @inlinable
  @inline(__always)
  public func prepend(_ value: T) {
    insert(value, at: 0)
  }

  /// Prepend a `LinkedListNode` to the start of the list.
  ///
  /// ⚠️ It is programmer's responsibility to make sure the node is not in the list.
  ///
  /// - Complexity: O(1)
  ///
  /// - Parameters:
  ///   - newNode: The node to prepend.
  ///   - copy: If the node should be copied. Default is `false`.
  @inlinable
  @inline(__always)
  public func prepend(_ newNode: Node, copy: Bool = false) {
    insert(newNode, copy: copy, at: 0)
  }

  /// Prepend a `LinkedList` to the start of the list.
  ///
  /// ⚠️ It is programmer's responsibility to make sure the list is not in the list.
  ///
  /// - Complexity: O(1) if the list is not copied, otherwise O(n).
  ///
  /// - Parameters:
  ///   - list: The list to be prepend.
  ///   - copy: If the list should be copied. Default is `false`.
  @inlinable
  @inline(__always)
  public func prepend(_ list: some LinkedListType<T>, copy: Bool = false) {
    insert(list, copy: copy, at: 0)
  }

  // MARK: - Insert

  /// Insert a value at a specific index.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  ///
  /// - Parameters:
  ///   - value: The value to be inserted.
  ///   - index: The index to be inserted at.
  @inlinable
  @inline(__always)
  public func insert(_ value: T, at index: Int) {
    insert(Node(value: value), copy: false, at: index)
  }

  /// Insert a node at a specific index.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  /// ⚠️ It is programmer's responsibility to make sure the node is not in the list.
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  ///
  /// - Parameters:
  ///   - node: The value to be copied and inserted.
  ///   - copy: If the node should be copied. Default is `false`.
  ///   - index: The index to be inserted at.
  public func insert(_ newNode: Node, copy: Bool = false, at index: Int) {
    let newNode = copy ? Node(value: newNode.value) : newNode
    if index == 0 {
      newNode.next = head
      head?.previous = newNode
      head = newNode
      if tail == nil {
        tail = newNode
      }
    } else {
      let prev = self.node(at: index - 1)
      let next = prev.next

      newNode.previous = prev
      newNode.next = prev.next
      prev.next = newNode
      next?.previous = newNode

      if next == nil {
        tail = newNode
      }
    }
  }

  /// Insert a `LinkedList` at a specific index.
  ///
  /// ⚠️ By default, the `list` is inserted without being copied.
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  /// ⚠️ It is programmer's responsibility to make sure the list is not in the list.
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  ///
  /// - Parameters:
  ///   - list: The list to be copied and inserted.
  ///   - copy: If the list should be copied. Default is `false`.
  ///   - index: The index to be inserted at.
  public func insert(_ list: some LinkedListType<T>, copy: Bool = false, at index: Int) {
    guard !list.isEmpty else {
      return
    }

    let list = copy ? list.copy() : list

    if index == 0 {
      list.last?.next = head
      head?.previous = list.last
      head = list.head

      if tail == nil {
        tail = list.tail
      }
    } else {
      let prev = node(at: index - 1)
      let next = prev.next

      prev.next = list.head
      list.head?.previous = prev

      list.last?.next = next
      next?.previous = list.last

      if next == nil {
        tail = list.tail
      }
    }
  }

  // MARK: - Remove

  /// Remove a node from the linked list.
  ///
  /// ⚠️ The node must be in the list.
  ///
  /// - Parameter node: The node to remove.
  /// - Returns: The value of the removed node.
  @discardableResult
  public func remove(node: Node) -> T {
    let prev = node.previous
    let next = node.next

    if let prev = prev {
      prev.next = next
    } else {
      head = next
    }
    next?.previous = prev

    if next == nil {
      tail = prev
    }

    node.previous = nil
    node.next = nil

    return node.value
  }

  /// Remove the first node in the list.
  ///
  /// ⚠️ Crashes if the list is empty.
  ///
  /// - Returns: The value of the removed node.
  @discardableResult
  public func removeFirst() -> T {
    return remove(at: 0)
  }

  /// Remove the last node in the list.
  ///
  /// ⚠️ Crashes if the list is empty.
  ///
  /// - Returns: The value of the removed node.
  @discardableResult
  public func removeLast() -> T {
    // swiftlint:disable:next force_unwrapping
    return remove(node: last!)
  }

  /// Remove a node/value at a specific index.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  ///
  /// - Parameter index: The index of the node to be removed.
  /// - Returns: The value of the removed node.
  @discardableResult
  public func remove(at index: Int) -> T {
    remove(node: node(at: index))
  }

  /// Removes and returns the first element in the list.
  ///
  /// - Returns: The first element or nil.
  public func popFirst() -> T? {
    guard !isEmpty else {
      return nil
    }
    return removeFirst()
  }

  /// Removes and returns the last element in the list.
  ///
  /// - Returns: The last element or nil.
  public func popLast() -> T? {
    guard !isEmpty else {
      return nil
    }
    return removeLast()
  }

  /// Removes all nodes from the linked list.
  ///
  /// - Complexity: O(1)
  public func removeAll() {
    head = nil
    tail = nil
  }

  // MARK: - Others

  /// Creates a copy of the linked list and returns it.
  ///
  /// - Returns: A new linked list containing all elements of the original list.
  /// - Complexity: O(n), where n is the number of elements in the list.
  public func copy() -> LinkedList {
    let copy = LinkedList()
    var node = head
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      copy.append(node!.value)
      // swiftlint:disable:next force_unwrapping
      node = node!.next
    }
    return copy
  }

  /// Reverse the linked list.
  ///
  /// - Complexity: O(n), where n is the number of elements in the list.
  public func reverse() {
    var node = head
    tail = node // If you had a tail pointer
    while let currentNode = node {
      node = currentNode.next
      swap(&currentNode.next, &currentNode.previous)
      head = currentNode
    }
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    var string = "LinkedList<\(T.self)>["
    var node = head
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      string += "\(node!.value)"
      // swiftlint:disable:next force_unwrapping
      node = node!.next
      if node != nil {
        string += ", "
      }
    }
    return string + "]"
  }
}

extension LinkedList: ExpressibleByArrayLiteral {

  public convenience init(arrayLiteral elements: T...) {
    self.init(elements)
  }
}

// MARK: - Sequence

extension LinkedList: Sequence {

  public struct Iterator: IteratorProtocol {

    private var currentNode: Node?

    fileprivate init(_ head: Node?) {
      self.currentNode = head
    }

    public mutating func next() -> Node? {
      let node = currentNode
      currentNode = currentNode?.next
      return node
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(head)
  }
}

// /// Custom index type that contains a reference to the node at index 'tag'
// public struct LinkedListIndex<T>: Comparable {
//
//     fileprivate let node: LinkedListNode<T>?
//     fileprivate let tag: Int
//
//     public static func==<T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
//         return (lhs.tag == rhs.tag)
//     }
//
//     public static func< <T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
//         return (lhs.tag < rhs.tag)
//     }
// }
//
// extension LinkedList: Collection {
//
//   public typealias Index = LinkedListIndex<T>
//
//   /// The position of the first element in a nonempty collection.
//   ///
//   /// If the collection is empty, `startIndex` is equal to `endIndex`.
//   /// - Complexity: O(1)
//   public var startIndex: Index {
//     LinkedListIndex<T>(node: head, tag: 0)
//   }
//
//   /// The collection's "past the end" position---that is, the position one
//   /// greater than the last valid subscript argument.
//   /// - Complexity: O(n), where n is the number of elements in the list. This can be improved by keeping a reference
//   ///   to the last node in the collection.
//   public var endIndex: Index {
//     if let h = self.head {
//       return LinkedListIndex<T>(node: h, tag: count)
//     } else {
//       return LinkedListIndex<T>(node: nil, tag: startIndex.tag)
//     }
//   }
//
//   public subscript(position: Index) -> T {
//     get {
//       return position.node!.value
//     }
//   }
//
//   public func index(after idx: Index) -> Index {
//     return LinkedListIndex<T>(node: idx.node?.next, tag: idx.tag + 1)
//   }
// }

// https://en.wikipedia.org/wiki/Linked_list
// https://en.wikipedia.org/wiki/Doubly_linked_list

// https://github.com/honghaoz/DataStructure-Algorithm/blob/master/Swift/LeetCode/Shared/ListNode.swift
// https://github.com/kodecocodes/swift-algorithm-club/blob/master/Linked%20List/README.markdown
