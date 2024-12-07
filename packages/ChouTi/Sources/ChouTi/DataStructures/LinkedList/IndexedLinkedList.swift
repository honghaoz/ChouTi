//
//  IndexedLinkedList.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/7/23.
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

/// A linked list implementation that is fast for queries, but may be slower for inserting and removing.
///
/// `IndexedLinkedList` is a custom implementation of a linked list that aims to provide fast querying capabilities
/// while potentially having slower insertions and removals compared to a regular linked list (`LinkedList`).
///
/// The main difference between `IndexedLinkedList` and a regular `LinkedList` lies in the way they handle querying.
/// `IndexedLinkedList` uses helper dictionaries to speed up the query process, allowing for faster access to nodes based
/// on their indices.
///
/// However, this comes at a cost, as the dictionaries need to be updated whenever there's an insertion or removal
/// in the list. This can lead to slower insertions and removals compared to a regular linked list (`LinkedList`).
///
/// Overall, `IndexedLinkedList` is a suitable choice when fast querying is a priority, and the potential slowdown
/// in insertions and removals is acceptable. If insertion and removal performance is more critical, consider
/// using a regular `LinkedList` instead.
public final class IndexedLinkedList<T>: LinkedListType, CustomStringConvertible {

  public typealias Node = LinkedListNode<T>

  /// The head of the linked list.
  public var head: Node? { linkedList.head }

  /// The tail of the linked list.
  public var tail: Node? { linkedList.tail }

  /// The head of the linked list.
  public var first: Node? { head }

  /// The tail of the linked list.
  public var last: Node? { tail }

  /// Returns `true` if the linked list has no nodes.
  public var isEmpty: Bool { indexToNode.isEmpty }

  /// The length of the linked list.
  public var count: Int { indexToNode.count }

  /// The helper dictionaries to speed up the query.
  private var nodeIdToIndex: [ObjectIdentifier: Int] = [:]
  private var indexToNode: [Int: Node] = [:]

  /// The backing linked list.
  private let linkedList: LinkedList<T>

  /// Initializes an empty IndexedLinkedList.
  public init() {
    linkedList = LinkedList<T>()
  }

  /// Initializes an IndexedLinkedList with the given value.
  ///
  /// - Parameter value: The value of the node.
  @inlinable
  @inline(__always)
  public convenience init(_ value: T) {
    self.init([value])
  }

  /// Initializes an IndexedLinkedList with the given array.
  ///
  /// - Parameter array: An array containing the elements to be added to the linked list.
  public init(_ array: [T]) {
    linkedList = LinkedList<T>(array)

    nodeIdToIndex.reserveCapacity(array.count)
    indexToNode.reserveCapacity(array.count)
    for (i, node) in linkedList.enumerated() {
      nodeIdToIndex[ObjectIdentifier(node)] = i
      indexToNode[i] = node
    }
  }

  /// Rebuilds the underlying query dictionaries.
  ///
  /// When you modify the linked list via child node or child list, the root list will not be aware of the changes.
  /// You should call this method on the root list to reflect the current state of the linked list.
  ///
  /// - Complexity: O(n), where n is the number of nodes in the linked list.
  public func rebuildIndex() {
    nodeIdToIndex.removeAll(keepingCapacity: true)
    indexToNode.removeAll(keepingCapacity: true)

    for (i, node) in linkedList.enumerated() {
      nodeIdToIndex[ObjectIdentifier(node)] = i
      indexToNode[i] = node
    }
  }

  // MARK: - Query

  /// Returns the node at the specified index in the linked list.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  ///
  /// This method retrieves the node at the given index using internal index dictionary,
  /// allowing for faster access compared to traversing the list from the head or tail.
  ///
  /// - Parameter index: The index of the node to retrieve. Must be a valid index within the list's bounds.
  /// - Returns: The node at the specified index.
  /// - Precondition: `index` must be within the bounds of the list, otherwise a runtime error will occur.
  /// - Complexity: O(1)
  public func node(at index: Int) -> Node {
    // swiftlint:disable:next force_unwrapping
    indexToNode[index]!
  }

  /// Returns the node at the specified index in the linked list.
  ///
  /// ⚠️ Crashes if the `index` is out of bounds [0...self.count]
  ///
  /// This method retrieves the node at the given index using internal index dictionary,
  /// allowing for faster access compared to traversing the list from the head or tail.
  ///
  /// - Parameter index: The index of the node to retrieve. Must be a valid index within the list's bounds.
  /// - Returns: The node at the specified index.
  /// - Precondition: `index` must be within the bounds of the list, otherwise a runtime error will occur.
  /// - Complexity: O(1)
  public subscript(index: Int) -> Node {
    // swiftlint:disable:next force_unwrapping
    indexToNode[index]!
  }

  /// Returns the index of the specified node in the linked list.
  ///
  /// - Parameter node: The node whose index is to be returned.
  /// - Returns: The index of the node, if found; otherwise, `nil`.
  /// - Complexity: O(1)
  public func index(of node: Node) -> Int? {
    nodeIdToIndex[ObjectIdentifier(node)]
  }

  // MARK: - Append

  /// Appends a new element to the end of the linked list.
  ///
  /// - Parameter value: The value to be appended to the list.
  /// - Complexity: O(1)
  public func append(_ value: T) {
    append(Node(value: value), copy: false)
  }

  /// Appends a new node to the end of the linked list, optionally copying the node.
  ///
  /// - Parameters:
  ///   - newNode: The node to be appended to the list.
  ///   - copy: If `true`, a copy of the node will be appended; otherwise, the original node will be used.
  /// - Complexity: O(1)
  public func append(_ newNode: LinkedListNode<T>, copy: Bool = false) {
    linkedList.append(newNode, copy: copy)

    // swiftlint:disable:next force_unwrapping
    let node = linkedList.last!
    let count = count
    nodeIdToIndex[ObjectIdentifier(node)] = count
    indexToNode[count] = node
  }

  /// Appends the elements of another linked list to the end of this linked list, optionally copying the nodes.
  ///
  /// - Parameters:
  ///   - list: The linked list whose elements will be appended.
  ///   - copy: If `true`, the nodes from the other list will be copied; otherwise, the original nodes will be used.
  /// - Complexity: O(n), where n is the number of elements in the other list.
  public func append(_ list: some LinkedListType<T>, copy: Bool = false) {
    linkedList.append(list, copy: copy)

    let startIndex = count

    var i = 0
    var node = list.head
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      nodeIdToIndex[ObjectIdentifier(node!)] = startIndex + i
      // swiftlint:disable:next force_unwrapping
      indexToNode[startIndex + i] = node!

      i += 1
      node = node?.next
    }
  }

  // MARK: - Prepend

  /// Prepend a value to the start of the list.
  ///
  /// - Parameter value: The node value to prepend.
  /// - Complexity: O(n)
  public func prepend(_ value: T) {
    insert(value, at: 0)
  }

  /// Prepend a `LinkedListNode` to the start of the list.
  ///
  /// - Parameter newNode: The node to prepend.
  /// - Parameter copy: If the node should be copied.
  /// - Complexity: O(n)
  public func prepend(_ newNode: LinkedListNode<T>, copy: Bool = false) {
    insert(newNode, copy: copy, at: 0)
  }

  /// Prepend a linked list to the start of the list.
  ///
  /// - Parameter list: The linked list to prepend.
  /// - Complexity: O(n)
  public func prepend(_ list: some LinkedListType<T>, copy: Bool = false) {
    insert(list, copy: copy, at: 0)
  }

  // MARK: - Insert

  /// Inserts a new element at the specified index in the linked list.
  ///
  /// - Parameters:
  ///   - value: The value to be inserted.
  ///   - index: The index at which the value should be inserted.
  /// - Complexity: O(n), where n is the number of elements after the insertion index.
  public func insert(_ value: T, at index: Int) {
    insert(Node(value: value), copy: false, at: index)
  }

  /// Inserts a new node at the specified index in the linked list, optionally copying the node.
  ///
  /// - Parameters:
  ///   - newNode: The node to be inserted.
  ///   - copy: If `true`, a copy of the node will be inserted; otherwise, the original node will be used.
  ///   - index: The index at which the node should be inserted.
  /// - Complexity: O(n), where n is the number of elements after the insertion index.
  public func insert(_ newNode: LinkedListNode<T>, copy: Bool = false, at index: Int) {
    linkedList.insert(newNode, copy: copy, at: index)

    // update dictionaries from the header since inserting a node using a sublist can affect the whole list

    let startIndex = index

    var i = 0
    var node: Node? = linkedList.node(at: index)
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      nodeIdToIndex[ObjectIdentifier(node!)] = startIndex + i
      // swiftlint:disable:next force_unwrapping
      indexToNode[startIndex + i] = node!

      i += 1
      node = node?.next
    }
  }

  /// Inserts the elements of another linked list at the specified index in this linked list, optionally copying the nodes.
  ///
  /// - Parameters:
  ///   - list: The linked list whose elements will be inserted.
  ///   - copy: If `true`, the nodes from the other list will be copied; otherwise, the original nodes will be used.
  ///   - index: The index at which the other list's elements should be inserted.
  /// - Complexity: O(n)
  public func insert(_ list: some LinkedListType<T>, copy: Bool = false, at index: Int) {
    guard !list.isEmpty else {
      return
    }
    linkedList.insert(list, copy: copy, at: index)

    // update dictionaries for nodes after index
    let startIndex = index

    var i = 0
    var node: Node? = linkedList.node(at: index)
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      nodeIdToIndex[ObjectIdentifier(node!)] = startIndex + i
      // swiftlint:disable:next force_unwrapping
      indexToNode[startIndex + i] = node!

      i += 1
      node = node?.next
    }
  }

  /// Removes the specified node from the linked list and returns the removed node's value.
  ///
  /// - Parameter node: The node to be removed from the list.
  /// - Returns: The value of the removed node.
  /// - Note: If the node is not found in the list, this method will cause a runtime error.
  /// - Complexity: O(n), where n is the number of elements after the removed node.
  @discardableResult
  public func remove(node: LinkedListNode<T>) -> T {
    guard let index = index(of: node) else {
      fatalError("Node not found in the list.") // swiftlint:disable:this fatal_error
    }

    let isTail = node === tail

    let value = linkedList.remove(node: node)

    // remove the removing node from the dictionaries
    nodeIdToIndex[ObjectIdentifier(node)] = nil
    indexToNode[index] = nil

    if !isTail {
      // decrement values by 1 for any item in nodeIdToIndex with an index that is greater than the removing index
      for (nodeId, idx) in nodeIdToIndex {
        if idx > index {
          nodeIdToIndex[nodeId] = idx - 1
        }
      }

      // decrement the key (index) by 1 for any item in indexToNode whose key is greater than the removing index
      var newIndexToNode: [Int: Node] = [:]
      for (idx, node) in indexToNode {
        if idx > index {
          newIndexToNode[idx - 1] = node
        } else if idx < index {
          newIndexToNode[idx] = node
        }
      }
      indexToNode = newIndexToNode
    }

    return value
  }

  // MARK: - Remove

  /// Removes the first node from the linked list and returns the removed node's value.
  ///
  /// - Returns: The value of the removed first node.
  /// - Complexity: O(n)
  @inlinable
  @inline(__always)
  @discardableResult
  public func removeFirst() -> T {
    // swiftlint:disable:next force_unwrapping
    remove(node: head!)
  }

  /// Removes the last node from the linked list and returns the removed node's value.
  ///
  /// - Returns: The value of the removed last node.
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public func removeLast() -> T {
    // swiftlint:disable:next force_unwrapping
    remove(node: last!)
  }

  /// Removes the node at the specified index from the linked list and returns the removed node's value.
  ///
  /// - Parameter index: The index of the node to be removed.
  /// - Returns: The value of the removed node.
  /// - Complexity: O(n), where n is the number of elements after the removed node.
  public func remove(at index: Int) -> T {
    // swiftlint:disable:next force_unwrapping
    remove(node: indexToNode[index]!)
  }

  /// Removes and returns the first element in the list.
  ///
  /// - Returns: The first element or nil.
  /// - Complexity: O(n)
  @discardableResult
  public func popFirst() -> T? {
    guard !isEmpty else {
      return nil
    }
    return removeFirst()
  }

  /// Removes and returns the last element in the list.
  ///
  /// - Returns: The last element or nil.
  /// - Complexity: O(1)
  @discardableResult
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
    linkedList.removeAll()

    nodeIdToIndex.removeAll()
    indexToNode.removeAll()
  }

  // MARK: - Other

  /// Creates a copy of the linked list and returns it.
  ///
  /// - Returns: A new linked list containing all elements of the original list.
  /// - Complexity: O(n), where n is the number of elements in the list.
  public func copy() -> IndexedLinkedList {
    let copy = IndexedLinkedList()
    var node = head
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      copy.append(node!.value)
      // swiftlint:disable:next force_unwrapping
      node = node!.next
    }
    return copy
  }

  /// Reverses the order of the nodes in the linked list.
  ///
  /// - Complexity: O(n), where n is the number of elements in the list.
  public func reverse() {
    linkedList.reverse()

    // update dictionaries
    var i = 0
    var node = head
    while node != nil {
      // swiftlint:disable:next force_unwrapping
      nodeIdToIndex[ObjectIdentifier(node!)] = i
      // swiftlint:disable:next force_unwrapping
      indexToNode[i] = node!

      i += 1
      node = node?.next
    }
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    linkedList.description
  }
}

extension IndexedLinkedList: ExpressibleByArrayLiteral {

  public convenience init(arrayLiteral elements: T...) {
    self.init(elements)
  }
}

// MARK: - Sequence

extension IndexedLinkedList: Sequence {

  public func makeIterator() -> LinkedList<T>.Iterator {
    linkedList.makeIterator()
  }
}
