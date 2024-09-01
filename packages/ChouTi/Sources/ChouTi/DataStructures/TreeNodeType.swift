//
//  TreeNodeType.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/15/24.
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

/// A protocol that represents a tree node.
public protocol TreeNodeType {

  associatedtype Node: TreeNodeType where Node.Node == Node

  /// The children of the node.
  var children: [Node] { get }

  /// Perform a block on the node and its children nodes in a bread-first search (BFS) order.
  /// - Parameter block: The block to perform on the node. Return `true` to stop the search.
  func performBlockBFS(_ block: (Node) -> Bool)

  /// Perform a block on the node and its children nodes in a depth-first search (DFS) order.
  /// - Parameter block: The block to perform on the node. Return `true` to stop the search.
  func performBlockDFS(_ block: (Node) -> Bool)
}

public extension TreeNodeType {

  func performBlockBFS(_ block: (Node) -> Bool) {
    let queue = Queue<Node>()
    queue.enqueue(self as! Node) // swiftlint:disable:this force_cast
    while !queue.isEmpty() {
      let node = queue.dequeue()! // swiftlint:disable:this force_unwrapping
      let stop = block(node)
      if stop {
        return
      }
      for child in node.children {
        queue.enqueue(child)
      }
    }
  }

  func performBlockDFS(_ block: (Node) -> Bool) {
    _ = performBlockDFSHelper(block)
  }

  private func performBlockDFSHelper(_ block: (Node) -> Bool) -> Bool {
    let stop = block(self as! Node) // swiftlint:disable:this force_cast
    if stop {
      return true
    }

    for child in children {
      if child.performBlockDFSHelper(block) {
        return true
      }
    }
    return false
  }
}
