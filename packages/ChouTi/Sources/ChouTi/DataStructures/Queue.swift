//
//  Queue.swift
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

import CoreGraphics

/// A standard queue (FIFO - First In First Out).
///
/// Example:
/// ```swift
/// let queue: Queue<Int> = [1, 2, 3]
/// queue.enqueue(4)
/// queue.enqueue(5)
/// queue.enqueue(6)
/// queue.dequeue() // 1
/// queue.dequeue() // 2
/// queue.dequeue() // 3
/// queue.dequeue() // 4
/// queue.dequeue() // 5
/// queue.dequeue() // 6
/// ```
///
/// - Note: This queue is not thread-safe. You should make sure `enqueue` and `dequeue` calls are made from the same thread.
public final class Queue<Element>: CustomStringConvertible {

  /// A single item in the queue.
  fileprivate final class Item<T> {

    let value: T
    var next: Item?

    init(_ value: T) {
      self.value = value
    }
  }

  private var head: Item<Element>?
  private var tail: Item<Element>?

  /// The number of items in the queue.
  public private(set) var count: Int = 0

  /// Initializes an empty queue.
  public init() {}

  /// Initializes a queue with the given elements.
  public convenience init(_ elements: [Element]) {
    self.init()
    for element in elements {
      enqueue(element)
    }
  }

  /// Initializes a queue with the given elements.
  public convenience init(_ elements: Element...) {
    self.init()
    for element in elements {
      enqueue(element)
    }
  }

  /// Enqueues a new item at the end of the queue.
  ///
  /// - Parameter value: A new value to enqueue.
  public func enqueue(_ value: Element) {
    let queueItem = Item(value)
    tail?.next = queueItem
    tail = queueItem
    if head == nil {
      head = tail
    }
    count += 1
  }

  /// Enqueues a list of values.
  ///
  /// - Parameter values: New values to enqueue.
  public func enqueue(_ values: [Element]) {
    for element in values {
      enqueue(element)
    }
  }

  /// Dequeues an item at the front of the queue.
  ///
  /// - Returns: The value dequeued.
  public func dequeue() -> Element? {
    if let value = head?.value {
      head = head?.next
      if head == nil {
        tail = nil
      }
      count -= 1
      return value
    }
    return nil
  }

  /// Checks if the queue is empty.
  public func isEmpty() -> Bool {
    head == nil
  }

  /// The next item in the queue.
  @inlinable
  @inline(__always)
  public var next: Element? {
    first
  }

  /// The first item in the queue.
  public var first: Element? {
    head?.value
  }

  /// The last item in the queue.
  public var last: Element? {
    tail?.value
  }

  /// Removes all items from the queue.
  public func removeAll() {
    head = nil
    tail = nil
    count = 0
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    if isEmpty() {
      return "Queue<\(Element.self)> []"
    }

    var string = "Queue<\(Element.self)> [\n"
    for (i, item) in enumerated() {
      string += "  \(i):\t\(item)\n"
    }

    string += "]"

    return string
  }
}

// MARK: - ExpressibleByArrayLiteral

extension Queue: ExpressibleByArrayLiteral {

  /// Initializes a queue with the given elements.
  public convenience init(arrayLiteral: Element...) {
    self.init()
    for element in arrayLiteral {
      enqueue(element)
    }
  }
}

// MARK: - Sequence

extension Queue: Sequence {

  public func makeIterator() -> Iterator {
    Iterator(current: head)
  }

  public struct Iterator: IteratorProtocol {

    private var current: Item<Element>?

    fileprivate init(current: Item<Element>?) {
      self.current = current
    }

    public mutating func next() -> Element? {
      defer {
        current = current?.next
      }
      if let current {
        return current.value
      }
      return nil
    }
  }

  // References:
  // https://www.swiftbysundell.com/articles/swift-sequences-the-art-of-being-lazy/
}

public extension Queue where Element == Int {

  /// Calculates the sum of all elements in the queue.
  ///
  /// - Returns: The sum of all elements.
  /// - Complexity: O(n), where n is the number of elements in the queue.
  func sum() -> Element {
    var sum: Element = 0
    for value in self {
      sum += value
    }
    return sum
  }
}

public extension Queue where Element == Double {

  /// Calculates the sum of all elements in the queue.
  ///
  /// - Returns: The sum of all elements.
  /// - Complexity: O(n), where n is the number of elements in the queue.
  func sum() -> Element {
    var sum: Element = 0
    for value in self {
      sum += value
    }
    return sum
  }
}

public extension Queue where Element == CGFloat {

  /// Calculates the sum of all elements in the queue.
  ///
  /// - Returns: The sum of all elements.
  /// - Complexity: O(n), where n is the number of elements in the queue.
  func sum() -> Element {
    var sum: Element = 0
    for value in self {
      sum += value
    }
    return sum
  }
}

public extension Queue where Element == Float {

  /// Calculates the sum of all elements in the queue.
  ///
  /// - Returns: The sum of all elements.
  /// - Complexity: O(n), where n is the number of elements in the queue.
  func sum() -> Element {
    var sum: Element = 0
    for value in self {
      sum += value
    }
    return sum
  }
}

// https://gist.github.com/kareman/931017634606b7f7b9c0
