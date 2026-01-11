//
//  QueueTests.swift
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

import ChouTiTest

import ChouTi

class QueueTests: XCTestCase {

  func test_init() {
    do {
      let queue = Queue<Int>()
      expect(queue.count) == 0
    }
    do {
      let queue = Queue<Int>([1, 2, 3])
      expect(queue.count) == 3
    }
    do {
      let queue = Queue<Int>(1, 2, 3)
      expect(queue.count) == 3
    }
  }

  func test_enqueue() {
    let queue = Queue<Int>()
    queue.enqueue(1)
    expect(queue.count) == 1
    expect(queue.first) == 1
    expect(queue.last) == 1

    queue.enqueue([2, 3, 4])
    expect(queue.count) == 4
    expect(queue.first) == 1
    expect(queue.last) == 4
  }

  func test_dequeue() {
    let queue = Queue<Int>()
    queue.enqueue(1)
    expect(queue.dequeue()) == 1
    expect(queue.count) == 0
    expect(queue.dequeue()) == nil

    queue.enqueue(1)
    queue.enqueue(2)
    expect(queue.dequeue()) == 1
    expect(queue.count) == 1
    expect(queue.first) == 2
    expect(queue.last) == 2
  }

  func test_isEmpty() {
    let queue = Queue<Int>()
    expect(queue.isEmpty()) == true
    queue.enqueue(1)
    expect(queue.isEmpty()) == false
  }

  func test_next() {
    let queue = Queue<Int>()
    expect(queue.next) == nil
    queue.enqueue(1)
    expect(queue.next) == 1
    queue.enqueue(2)
    expect(queue.next) == 1
  }

  func test_first() {
    let queue = Queue<Int>()
    expect(queue.first) == nil
    queue.enqueue(1)
    expect(queue.first) == 1
    queue.enqueue(2)
    expect(queue.first) == 1
  }

  func test_last() {
    let queue = Queue<Int>()
    expect(queue.last) == nil
    queue.enqueue(1)
    expect(queue.last) == 1
    queue.enqueue(2)
    expect(queue.last) == 2
  }

  func test_removeAll() {
    let queue = Queue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)
    queue.removeAll()
    expect(queue.count) == 0
    expect(queue.first) == nil
    expect(queue.last) == nil
  }

  func test_optional() {
    let queue = Queue<Int?>()
    queue.enqueue(nil)
    queue.enqueue(nil)
    expect(String(describing: queue.dequeue())) == "Optional(nil)"
    expect(queue.dequeue()!) == nil // swiftlint:disable:this force_unwrapping

    expect(queue.count) == 0

    queue.enqueue(1)
    expect(queue.dequeue()) == 1

    queue.enqueue(nil)
    expect(String(describing: queue.dequeue())) == "Optional(nil)"
  }

  func test_debugDescription() {
    let queue = Queue<String>()
    expect(queue.description) == "Queue<String> []"
    queue.enqueue(["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"])
    expect(queue.description) == """
    Queue<String> [
      0:\ta
      1:\tb
      2:\tc
      3:\td
      4:\te
      5:\tf
      6:\tg
      7:\th
      8:\ti
      9:\tj
      10:\tk
      11:\tl
      12:\tm
    ]
    """
  }

  // MARK: - ExpressibleByArrayLiteral

  func testInitializationWithArrayLiteral() {
    // Test with integers
    let intQueue: Queue<Int> = [1, 2, 3, 4, 5]
    expect(intQueue.count) == 5
    expect(intQueue.dequeue()) == 1
    expect(intQueue.dequeue()) == 2
    expect(intQueue.count) == 3

    // Test with strings
    let stringQueue: Queue<String> = ["a", "b", "c"]
    expect(stringQueue.count) == 3
    expect(stringQueue.dequeue()) == "a"
    expect(stringQueue.count) == 2

    // Test with empty array literal
    let emptyQueue: Queue<Double> = []
    expect(emptyQueue.isEmpty()) == true
    expect(emptyQueue.count) == 0
  }

  // MARK: - Sequence

  func test_sequence() {
    let queue = Queue<Int>()
    queue.enqueue(1)
    queue.enqueue(2)
    queue.enqueue(3)
    expect(queue.map { $0 * 2 }) == [2, 4, 6]
  }

  // MARK: - Sum

  func test_sum() {
    // Int
    do {
      let queue = Queue<Int>()
      queue.enqueue(1)
      queue.enqueue(2)
      queue.enqueue(3)
      expect(queue.sum()) == 6
    }

    // Double
    do {
      let queue = Queue<Double>()
      queue.enqueue(1.1)
      queue.enqueue(2.2)
      queue.enqueue(3.3)
      expect(queue.sum()) == 6.6
    }

    // CGFloat
    do {
      let queue = Queue<CGFloat>()
      queue.enqueue(1.1)
      queue.enqueue(2.2)
      queue.enqueue(3.3)
      expect(queue.sum()) == 6.6
    }

    // Float
    do {
      let queue = Queue<Float>()
      queue.enqueue(1.1)
      queue.enqueue(2.2)
      queue.enqueue(3.3)
      expect(queue.sum()) == 6.6000004
    }
  }
}
