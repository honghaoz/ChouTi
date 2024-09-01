//
//  IndexedLinkedListTests.swift
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

import ChouTiTest

import ChouTi

final class IndexedLinkedListTests: XCTestCase {

  func testEmptyLinkedList() {
    let list = IndexedLinkedList<Int>()
    expect(list.isEmpty) == true
    expect(list.count) == 0
    expect(list.head) == nil
    expect(list.tail) == nil
    expect(list.first) == nil
    expect(list.last) == nil
  }

  func testInitWithArray() {
    let list = IndexedLinkedList<Int>([1, 2, 3])
    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3
  }

  func testInitWithArrayLiteral() {
    let list: IndexedLinkedList<Int> = [1, 2, 3]
    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3
  }

  func testIndexOfNode() {
    let list = IndexedLinkedList<Int>()
    let node1 = LinkedListNode<Int>(value: 1)
    let node2 = LinkedListNode<Int>(value: 2)
    let node3 = LinkedListNode<Int>(value: 3)
    list.append(node1, copy: false)
    list.append(node2, copy: false)
    list.append(node3, copy: false)

    expect(list.index(of: node1)) == 0
    expect(list.index(of: node2)) == 1
    expect(list.index(of: node3)) == 2

    // for foreign node
    let node4 = LinkedListNode<Int>(value: 4)
    expect(list.index(of: node4)) == nil
  }

  // MARK: - Append

  func testAppendValue() {
    let list = IndexedLinkedList<Int>()
    list.append(1)
    list.append(2)
    list.append(3)

    expect(list.isEmpty) == false
    expect(list.count) == 3
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3

    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3
  }

  func testAppendOneValue() {
    let list = IndexedLinkedList<Int>()
    list.append(1)

    expect(list.isEmpty) == false
    expect(list.count) == 1
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 1
    expect(list.last?.value) == 1

    expect(list.node(at: 0).value) == 1

    expect(list[0].value) == 1
  }

  func testAppendNodeWithoutCopying() {
    let list = IndexedLinkedList<Int>()
    let node1 = LinkedListNode<Int>(value: 1)
    let node2 = LinkedListNode<Int>(value: 2)
    let node3 = LinkedListNode<Int>(value: 3)
    list.append(node1, copy: false)
    list.append(node2, copy: false)
    list.append(node3, copy: false)

    expect(list.isEmpty) == false
    expect(list.count) == 3
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3

    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3

    // if change node's value, the list's node value is affected
    node1.value = 4
    expect(list[0].value) == 4
    expect(list[1].value) == 2
    expect(list[2].value) == 3

    node2.value = 5
    expect(list[0].value) == 4
    expect(list[1].value) == 5
    expect(list[2].value) == 3

    node3.value = 6
    expect(list[0].value) == 4
    expect(list[1].value) == 5
    expect(list[2].value) == 6
  }

  func testAppendNodeWithCopying() {
    let list = IndexedLinkedList<Int>()
    let node1 = LinkedListNode<Int>(value: 1)
    let node2 = LinkedListNode<Int>(value: 2)
    let node3 = LinkedListNode<Int>(value: 3)
    list.append(node1, copy: true)
    list.append(node2, copy: true)
    list.append(node3, copy: true)

    expect(list.isEmpty) == false
    expect(list.count) == 3
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3

    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3

    // if change node's value, the list's node value is not affected
    node1.value = 4
    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3

    node2.value = 5
    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3

    node3.value = 6
    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3
  }

  func testAppendListWithoutCopying() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let list2 = IndexedLinkedList<Int>()
    list2.append(4)
    list2.append(5)
    list2.append(6)

    list.append(list2, copy: false)

    expect(list.count) == 6
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 6

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4
    expect(list.node(at: 4).value) == 5
    expect(list.node(at: 5).value) == 6

    // insert a node in list2, list should be updated
    list2.insert(LinkedListNode<Int>(value: 7), copy: false, at: 1)

    list.rebuildIndex()

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4
    expect(list.node(at: 4).value) == 7
    expect(list.node(at: 5).value) == 5
    expect(list.node(at: 6).value) == 6
  }

  func testAppendListWithoutCopying_whenListIsEmpty() {
    let list = IndexedLinkedList<Int>()

    let list2 = IndexedLinkedList<Int>()
    list2.append(4)
    list2.append(5)
    list2.append(6)

    list.append(list2, copy: false)

    expect(list.count) == 3
    expect(list.head?.value) == 4
    expect(list.tail?.value) == 6

    expect(list.node(at: 0).value) == 4
    expect(list.node(at: 1).value) == 5
    expect(list.node(at: 2).value) == 6
  }

  func testAppendListWithCopying() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let list2 = IndexedLinkedList<Int>()
    list2.append(4)
    list2.append(5)
    list2.append(6)

    list.append(list2, copy: true)

    expect(list.count) == 6
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 6

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4
    expect(list.node(at: 4).value) == 5
    expect(list.node(at: 5).value) == 6

    // if insert a node in list2, list is not affected
    list2.insert(LinkedListNode<Int>(value: 7), copy: false, at: 1)

    expect(list.node(at: 3).value) == 4
    expect(list.node(at: 4).value) == 5
    expect(list.node(at: 5).value) == 6
  }

  // MARK: - Prepend

  func testPrependValue() {
    let list = IndexedLinkedList<Int>()
    list.prepend(3)
    list.prepend(2)
    list.prepend(1)

    expect(list.isEmpty) == false
    expect(list.count) == 3
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3

    expect(list[0].value) == 1
    expect(list[1].value) == 2
    expect(list[2].value) == 3
  }

  func testPrependOneValue() {
    let list = IndexedLinkedList<Int>()
    list.prepend(1)

    expect(list.isEmpty) == false
    expect(list.count) == 1
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 1
    expect(list.last?.value) == 1

    expect(list.node(at: 0).value) == 1

    expect(list[0].value) == 1
  }

  func testPrependNodeWithoutCopying() {
    let list = IndexedLinkedList<Int>()
    let node1 = LinkedListNode<Int>(value: 1)
    let node2 = LinkedListNode<Int>(value: 2)
    let node3 = LinkedListNode<Int>(value: 3)
    list.prepend(node1, copy: false)
    list.prepend(node2, copy: false)
    list.prepend(node3, copy: false)

    expect(list.isEmpty) == false
    expect(list.count) == 3
    expect(list.head?.value) == 3
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 3
    expect(list.last?.value) == 1

    expect(list.node(at: 0).value) == 3
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 1

    expect(list[0].value) == 3
    expect(list[1].value) == 2
    expect(list[2].value) == 1

    // if change node's value, the list's node value is affected
    node1.value = 4
    expect(list[0].value) == 3
    expect(list[1].value) == 2
    expect(list[2].value) == 4

    node2.value = 5
    expect(list[0].value) == 3
    expect(list[1].value) == 5
    expect(list[2].value) == 4

    node3.value = 6
    expect(list[0].value) == 6
    expect(list[1].value) == 5
    expect(list[2].value) == 4
  }

  func testPrependNodeWithCopying() {
    let list = IndexedLinkedList<Int>()
    let node1 = LinkedListNode<Int>(value: 1)
    let node2 = LinkedListNode<Int>(value: 2)
    let node3 = LinkedListNode<Int>(value: 3)
    list.prepend(node1, copy: true)
    list.prepend(node2, copy: true)
    list.prepend(node3, copy: true)

    expect(list.isEmpty) == false
    expect(list.count) == 3
    expect(list.head?.value) == 3
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 3
    expect(list.last?.value) == 1

    expect(list.node(at: 0).value) == 3
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 1

    expect(list[0].value) == 3
    expect(list[1].value) == 2
    expect(list[2].value) == 1

    // if change node's value, the list's node value is not affected
    node1.value = 4
    expect(list[0].value) == 3
    expect(list[1].value) == 2
    expect(list[2].value) == 1

    node2.value = 5
    expect(list[0].value) == 3
    expect(list[1].value) == 2
    expect(list[2].value) == 1

    node3.value = 6
    expect(list[0].value) == 3
    expect(list[1].value) == 2
    expect(list[2].value) == 1
  }

  func testPrependListWithoutCopying() {
    let list = IndexedLinkedList<Int>()
    list.append(1)
    list.append(2)
    list.append(3)

    let list2 = IndexedLinkedList<Int>()
    list2.append(4)
    list2.append(5)
    list2.append(6)

    list.prepend(list2, copy: false)

    expect(list.count) == 6
    expect(list.head?.value) == 4
    expect(list.tail?.value) == 3

    expect(list.node(at: 0).value) == 4
    expect(list.node(at: 1).value) == 5
    expect(list.node(at: 2).value) == 6
    expect(list.node(at: 3).value) == 1
    expect(list.node(at: 4).value) == 2
    expect(list.node(at: 5).value) == 3

    // if insert a node in list2, list is affected
    list2.insert(LinkedListNode<Int>(value: 7), copy: false, at: 1)

    list.rebuildIndex()

    expect(list.node(at: 0).value) == 4
    expect(list.node(at: 1).value) == 7
    expect(list.node(at: 2).value) == 5
    expect(list.node(at: 3).value) == 6
    expect(list.node(at: 4).value) == 1
    expect(list.node(at: 5).value) == 2
    expect(list.node(at: 6).value) == 3
  }

  func testPrependListWithoutCopying_whenListIsEmpty() {
    let list = IndexedLinkedList<Int>()

    let list2 = IndexedLinkedList<Int>()
    list2.append(4)
    list2.append(5)
    list2.append(6)

    list.prepend(list2, copy: false)

    expect(list.count) == 3
    expect(list.head?.value) == 4
    expect(list.tail?.value) == 6

    expect(list.node(at: 0).value) == 4
    expect(list.node(at: 1).value) == 5
    expect(list.node(at: 2).value) == 6
  }

  // MARK: - Insert

  func testInsertValue() {
    let list = IndexedLinkedList<Int>()
    list.append(1)
    list.append(3)
    list.insert(2, at: 1)

    expect(list.count) == 3
    expect(list.node(at: 1).value) == 2

    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
  }

  func testInsertNode_whenListIsEmpty_insertAtZero() {
    let list = IndexedLinkedList<Int>()
    let node = LinkedListNode<Int>(value: 1)
    list.insert(node, at: 0)

    expect(list.count) == 1
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 1
    expect(list.last?.value) == 1

    // node is not copied
    expect(node) === list.head

    expect(list.node(at: 0).value) == 1
  }

  func testInsertNode_whenListIsNotEmpty_insertAtZero() {
    let list: IndexedLinkedList<Int> = [2]
    let node = LinkedListNode<Int>(value: 1)
    list.insert(node, at: 0)

    expect(list.count) == 2
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 2
    expect(list.first?.value) == 1
    expect(list.last?.value) == 2

    expect(list.node(at: 0).value) == 1
    expect(list.tail?.value) == 2
    expect(list.first?.value) == 1
    expect(list.last?.value) == 2

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2

    // node is not copied
    expect(node) === list.head
  }

  func testInsertNode_whenListIsNotEmpty_insertAtOne() {
    let list: IndexedLinkedList<Int> = [1]
    let node = LinkedListNode<Int>(value: 2)
    list.insert(node, at: 1)

    expect(list.count) == 2
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 2
    expect(list.first?.value) == 1
    expect(list.last?.value) == 2

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2

    // node is not copied
    expect(node) === list.tail
  }

  func testInsertNode_whenListIsEmpty_insertAtZero_copy() {
    let list = IndexedLinkedList<Int>()
    let node = LinkedListNode<Int>(value: 1)
    list.insert(node, copy: true, at: 0)

    expect(list.count) == 1
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 1
    expect(list.last?.value) == 1

    // node is not copied
    expect(node) !== list.head

    expect(list.node(at: 0).value) == 1
  }

  func testInsertNode_whenListIsNotEmpty_insertAtZero_copy() {
    let list: IndexedLinkedList<Int> = [2]
    let node = LinkedListNode<Int>(value: 1)
    list.insert(node, copy: true, at: 0)

    expect(list.count) == 2
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 2
    expect(list.first?.value) == 1
    expect(list.last?.value) == 2

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2

    // node is not copied
    expect(node) !== list.head
  }

  func testInsertNode_whenListIsNotEmpty_insertAtOne_copy() {
    let list: IndexedLinkedList<Int> = [1]
    let node = LinkedListNode<Int>(value: 2)
    list.insert(node, copy: true, at: 1)

    expect(list.count) == 2
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 2
    expect(list.first?.value) == 1
    expect(list.last?.value) == 2

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2

    // node is not copied
    expect(node) !== list.tail
  }

  func testInsertList_whenListIsEmpty_insertAtZero() {
    let list = IndexedLinkedList<Int>()
    let otherList: IndexedLinkedList<Int> = [1, 2, 3]
    list.insert(otherList, at: 0)

    expect(list.count) == 3
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3

    // list is not copied
    expect(otherList.head) === list.head
    expect(otherList.tail) === list.tail
    expect(otherList.node(at: 1)) === list.node(at: 1)
  }

  func testInsertList_whenListIsNotEmpty_insertAtZero() {
    let list: IndexedLinkedList<Int> = [4]
    let otherList: IndexedLinkedList<Int> = [1, 2, 3]
    list.insert(otherList, at: 0)

    expect(list.count) == 4
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 4
    expect(list.first?.value) == 1
    expect(list.last?.value) == 4

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4

    // list is not copied
    expect(otherList.head) === list.head
    expect(otherList.tail) === list.node(at: 2)
    expect(otherList.node(at: 1)) === list.node(at: 1)
  }

  func testInsertList_whenListIsNotEmpty_insertAtOne() {
    let list: IndexedLinkedList<Int> = [1]
    let otherList: IndexedLinkedList<Int> = [2, 3, 4]
    list.insert(otherList, at: 1)

    expect(list.count) == 4
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 4
    expect(list.first?.value) == 1
    expect(list.last?.value) == 4

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4

    // list is not copied
    expect(otherList.head) === list.node(at: 1)
    expect(otherList.tail) === list.tail
    expect(otherList.node(at: 1)) === list.node(at: 2)
  }

  func testInsertList_whenListIsNotEmpty_insertEmptyList() {
    let list: IndexedLinkedList<Int> = [1]
    let otherList = IndexedLinkedList<Int>()
    list.insert(otherList, at: 1)

    expect(list.count) == 1
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 1
    expect(list.first?.value) == 1
    expect(list.last?.value) == 1
  }

  func testInsertList_whenListIsEmpty_insertAtZero_copy() {
    let list = IndexedLinkedList<Int>()
    let otherList: IndexedLinkedList<Int> = [1, 2, 3]
    list.insert(otherList, copy: true, at: 0)

    expect(list.count) == 3
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 3
    expect(list.first?.value) == 1
    expect(list.last?.value) == 3

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3

    // list is copied
    expect(otherList.head) !== list.head
    expect(otherList.tail) !== list.tail
    expect(otherList.node(at: 1)) !== list.node(at: 1)
  }

  func testInsertList_whenListIsNotEmpty_insertAtZero_copy() {
    let list: IndexedLinkedList<Int> = [4]
    let otherList: IndexedLinkedList<Int> = [1, 2, 3]
    list.insert(otherList, copy: true, at: 0)

    expect(list.count) == 4
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 4
    expect(list.first?.value) == 1
    expect(list.last?.value) == 4

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4

    // list is copied
    expect(otherList.head) !== list.head
    expect(otherList.tail) !== list.node(at: 2)
    expect(otherList.node(at: 1)) !== list.node(at: 1)
  }

  func testInsertList_whenListIsNotEmpty_insertAtOne_copy() {
    let list: IndexedLinkedList<Int> = [1]
    let otherList: IndexedLinkedList<Int> = [2, 3, 4]
    list.insert(otherList, copy: true, at: 1)

    expect(list.count) == 4
    expect(list.head?.value) == 1
    expect(list.tail?.value) == 4
    expect(list.first?.value) == 1
    expect(list.last?.value) == 4

    expect(list.node(at: 0).value) == 1
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 3
    expect(list.node(at: 3).value) == 4

    // list is copied
    expect(otherList.head) !== list.node(at: 1)
    expect(otherList.tail) !== list.tail
    expect(otherList.node(at: 1)) !== list.node(at: 2)
  }

  // MARK: - Remove

  func testRemoveNode_head() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let node = list.node(at: 0)
    let removedValue = list.remove(node: node)
    expect(removedValue) == 1
    expect(list.count) == 2
    expect(list.node(at: 0).value) == 2
  }

  func testRemoveNode_middle() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let node = list.node(at: 1)
    let removedValue = list.remove(node: node)
    expect(removedValue) == 2
    expect(list.count) == 2
    expect(list.node(at: 1).value) == 3
  }

  func testRemoveNode_tail() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let node = list.node(at: 2)
    let removedValue = list.remove(node: node)
    expect(removedValue) == 3
    expect(list.count) == 2
    expect(list.node(at: 1).value) == 2
  }

  func testRemoveFirst() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.removeFirst()
    expect(removedValue) == 1
    expect(list.count) == 2
    expect(list.node(at: 0).value) == 2
  }

  func testRemoveLast() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.removeLast()
    expect(removedValue) == 3
    expect(list.count) == 2
    expect(list.node(at: 1).value) == 2
  }

  func testRemoveAtIndex_first() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.remove(at: 0)
    expect(removedValue) == 1
    expect(list.count) == 2
    expect(list.node(at: 0).value) == 2
  }

  func testRemoveAtIndex_middle() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.remove(at: 1)
    expect(removedValue) == 2
    expect(list.count) == 2
    expect(list.node(at: 1).value) == 3
  }

  func testRemoveAtIndex_last() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.remove(at: 2)
    expect(removedValue) == 3
    expect(list.count) == 2
    expect(list.node(at: 1).value) == 2
  }

  func testPopFirst() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.popFirst()
    expect(removedValue) == 1
    expect(list.count) == 2
    expect(list.node(at: 0).value) == 2
  }

  func testPopFirst_emptyList() {
    let list = IndexedLinkedList<Int>()

    let removedValue = list.popFirst()
    expect(removedValue) == nil
    expect(list.count) == 0
  }

  func testPopLast() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let removedValue = list.popLast()
    expect(removedValue) == 3
    expect(list.count) == 2
    expect(list.node(at: 1).value) == 2
  }

  func testPopLast_emptyList() {
    let list = IndexedLinkedList<Int>()

    let removedValue = list.popLast()
    expect(removedValue) == nil
    expect(list.count) == 0
  }

  func testRemoveAll() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    list.removeAll()
    expect(list.isEmpty) == true
    expect(list.count) == 0
    expect(list.head) == nil
    expect(list.tail) == nil
  }

  func testDescription_empty() {
    let list = IndexedLinkedList<Int>()

    expect(list.description) == "LinkedList<Int>[]"
  }

  func testDescription() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    expect(list.description) == "LinkedList<Int>[1, 2, 3]"
  }

  func testCopy() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    let copy = list.copy()
    expect(copy.count) == 3
    expect(copy.head?.value) == 1
    expect(copy.tail?.value) == 3
    expect(copy.first?.value) == 1
    expect(copy.last?.value) == 3

    expect(copy.node(at: 0).value) == 1
    expect(copy.node(at: 1).value) == 2
    expect(copy.node(at: 2).value) == 3

    // list is copied
    expect(list.head) !== copy.head
    expect(list.tail) !== copy.tail
    expect(list.node(at: 1)) !== copy.node(at: 1)
  }

  func testReverse() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    list.reverse()
    expect(list.count) == 3
    expect(list.head?.value) == 3
    expect(list.tail?.value) == 1

    expect(list.node(at: 0).value) == 3
    expect(list.node(at: 1).value) == 2
    expect(list.node(at: 2).value) == 1
  }

  func testSequence() {
    let list = IndexedLinkedList<Int>([1, 2, 3])

    for (index, node) in list.enumerated() {
      expect(index + 1) == node.value
    }
  }

  func testNodesAreReleasedAfterRemoveAll() {
    let list = IndexedLinkedList<Int>([1, 2, 3])
    weak var weakNode0: LinkedListNode<Int>? = list.node(at: 0)
    weak var weakNode1: LinkedListNode<Int>? = list.node(at: 1)
    weak var weakNode2: LinkedListNode<Int>? = list.node(at: 2)

    expect(weakNode0) != nil
    expect(weakNode1) != nil
    expect(weakNode2) != nil

    list.removeAll()
    expect(weakNode0) == nil
    expect(weakNode1) == nil
    expect(weakNode2) == nil
  }
}
