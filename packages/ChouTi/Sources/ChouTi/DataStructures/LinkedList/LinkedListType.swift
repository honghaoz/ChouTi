//
//  LinkedListType.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/8/23.
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

/// A protocol that represents a linked list.
public protocol LinkedListType<T>: Sequence, ExpressibleByArrayLiteral, CustomStringConvertible {

  associatedtype T

  /// Initializes an empty linked list.
  init()

  /// Initializes a linked list with the given value.
  ///
  /// - Parameter value: The value of the node.
  init(_ value: T)

  /// Initializes a linked list with the given array.
  ///
  /// - Parameter array: An array of values.
  init(_ array: [T])

  /// The head of the linked list.
  var head: LinkedListNode<T>? { get }

  /// The tail of the linked list.
  var tail: LinkedListNode<T>? { get }

  /// The head of the linked list.
  var first: LinkedListNode<T>? { get }

  /// The tail of the linked list.
  var last: LinkedListNode<T>? { get }

  /// Returns `true` if the linked list has no nodes.
  var isEmpty: Bool { get }

  /// The length of the linked list.
  var count: Int { get }

  // MARK: - Query

  /// Returns the node at the given index.
  ///
  /// - Parameter index: The index of the node.
  /// - Returns: The node at the given index.
  func node(at index: Int) -> LinkedListNode<T>

  /// Returns the node at the given index.
  ///
  /// - Parameter index: The index of the node.
  /// - Returns: The node at the given index.
  subscript(index: Int) -> LinkedListNode<T> { get }

  /// Returns the index of the given node.
  ///
  /// - Parameter node: The node to find the index of.
  /// - Returns: The index of the given node.
  func index(of node: LinkedListNode<T>) -> Int?

  // MARK: - Append

  /// Appends a value to the end of the linked list.
  ///
  /// - Parameter value: The value to append.
  func append(_ value: T)

  /// Appends a node to the end of the linked list.
  ///
  /// - Parameter newNode: The node to append.
  /// - Parameter copy: If the node should be copied.
  func append(_ newNode: LinkedListNode<T>, copy: Bool)

  /// Appends a linked list to the end of the linked list.
  ///
  /// - Parameter list: The linked list to append.
  /// - Parameter copy: If the linked list should be copied.
  func append(_ list: some LinkedListType<T>, copy: Bool)

  // MARK: - Prepend

  /// Prepend a value to the start of the list.
  ///
  /// - Parameter value: The node value to prepend.
  func prepend(_ value: T)

  /// Prepend a `LinkedListNode` to the start of the list.
  ///
  /// - Parameter newNode: The node to prepend.
  /// - Parameter copy: If the node should be copied.
  func prepend(_ newNode: LinkedListNode<T>, copy: Bool)

  /// Prepend a linked list to the start of the list.
  ///
  /// - Parameter list: The linked list to prepend.
  /// - Parameter copy: If the linked list should be copied.
  func prepend(_ list: some LinkedListType<T>, copy: Bool)

  // MARK: - Insert

  /// Inserts a value at the given index.
  ///
  /// - Parameter value: The value to insert.
  /// - Parameter index: The index at which to insert the value.
  func insert(_ value: T, at index: Int)

  /// Inserts a node at the given index.
  ///
  /// - Parameter newNode: The node to insert.
  /// - Parameter copy: If the node should be copied.
  /// - Parameter index: The index at which to insert the node.
  func insert(_ newNode: LinkedListNode<T>, copy: Bool, at index: Int)

  /// Inserts a linked list at the given index.
  ///
  /// - Parameter list: The linked list to insert.
  /// - Parameter copy: If the linked list should be copied.
  /// - Parameter index: The index at which to insert the linked list.
  func insert(_ list: some LinkedListType<T>, copy: Bool, at index: Int)

  // MARK: - Remove

  /// Removes a node from the linked list.
  ///
  /// - Parameter node: The node to remove.
  /// - Returns: The value of the removed node.
  @discardableResult func remove(node: LinkedListNode<T>) -> T

  /// Removes the first node from the linked list.
  ///
  /// - Returns: The value of the removed node.
  @discardableResult func removeFirst() -> T

  /// Removes the last node from the linked list.
  ///
  /// - Returns: The value of the removed node.
  @discardableResult func removeLast() -> T

  /// Removes a node from the linked list at the given index.
  ///
  /// - Parameter index: The index of the node to remove.
  /// - Returns: The value of the removed node.
  @discardableResult func remove(at index: Int) -> T

  /// Removes and returns the first element in the list.
  ///
  /// - Returns: The first element or nil.
  @discardableResult func popFirst() -> T?

  /// Removes and returns the last element in the list.
  ///
  /// - Returns: The last element or nil.
  @discardableResult func popLast() -> T?

  /// Removes all nodes from the linked list.
  func removeAll()

  /// Returns a copy of the linked list.
  ///
  /// - Returns: A copy of the linked list.
  func copy() -> Self

  /// Reverses the linked list.
  func reverse()
}
