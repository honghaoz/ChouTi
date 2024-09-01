//
//  TreeNodeTypeTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/17/24.
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

class TreeNodeTypeTests: XCTestCase {

  private class MockTreeNode: TreeNodeType {

    var value: Int
    var children: [MockTreeNode]

    init(value: Int, children: [MockTreeNode] = []) {
      self.value = value
      self.children = children
    }
  }

  // Helper method to create a sample tree for testing
  private func createSampleTree() -> MockTreeNode {
    // 1
    // 2  3
    // 45 67
    let node7 = MockTreeNode(value: 7)
    let node6 = MockTreeNode(value: 6)
    let node5 = MockTreeNode(value: 5)
    let node4 = MockTreeNode(value: 4)
    let node3 = MockTreeNode(value: 3, children: [node6, node7])
    let node2 = MockTreeNode(value: 2, children: [node4, node5])
    let node1 = MockTreeNode(value: 1, children: [node2, node3])
    return node1
  }

  func testBFSFullTraversal() {
    let root = createSampleTree()
    var result: [Int] = []

    root.performBlockBFS { node in
      result.append(node.value)
      return false
    }

    expect(result) == [1, 2, 3, 4, 5, 6, 7]
  }

  func testBFSEarlyStop() {
    let root = createSampleTree()
    var result: [Int] = []

    root.performBlockBFS { node in
      result.append(node.value)
      return node.value == 4 // early stop
    }

    expect(result) == [1, 2, 3, 4]
  }

  func testDFSFulTraversal() {
    let root = createSampleTree()
    var result: [Int] = []

    root.performBlockDFS { node in
      result.append(node.value)
      return false
    }

    expect(result) == [1, 2, 4, 5, 3, 6, 7]
  }

  func testDFSEarlyStop() {
    let root = createSampleTree()
    var result: [Int] = []

    root.performBlockDFS { node in
      result.append(node.value)
      return node.value == 4 // early stop
    }

    expect(result) == [1, 2, 4]
  }
}
