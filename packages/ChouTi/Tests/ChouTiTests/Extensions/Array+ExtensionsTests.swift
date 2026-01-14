//
//  Array+ExtensionsTests.swift
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

class Array_ExtensionsTests: XCTestCase {

  func test_removingDuplicates() {
    var integers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    expect(integers.removingDuplicates()) == [1, 2, 3, 4, 5]

    expect(integers) == [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    integers.removeDuplicates()
    expect(integers) == [1, 2, 3, 4, 5]
  }

  func test_unique() {
    let integers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    expect(integers.removingDuplicates()) == [1, 2, 3, 4, 5]
  }

  func test_allUnique() {
    let nonUniqueIntegers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    expect(nonUniqueIntegers.allUnique()) == false

    let uniqueIntegers = [1, 2, 3, 4, 5]
    expect(uniqueIntegers.allUnique()) == true

    let empty: [Int] = []
    expect(empty.allUnique()) == true
  }

  func test_asSet() {
    expect(["a", "b", "c", "c"].asSet()) == Set(["a", "b", "c"])
  }

  func test_allEqual() {
    let nonEqualIntegers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    expect(nonEqualIntegers.allEqual()) == false

    let equalIntegers = [1, 1, 1, 1, 1]
    expect(equalIntegers.allEqual()) == true

    let empty: [Int] = []
    expect(empty.allEqual()) == true
  }

  func test_removingFirstElement() {
    expect(["ni", "hao", "ma", "?"].removingFirstElement("hao")) == ["ni", "ma", "?"]
    expect(["ni", "hao", "ma", "?"].removingFirstElement("hao")) == ["ni", "ma", "?"]

    // duplicated elements
    expect(["1", "2", "3", "2", "4", "2"].removingFirstElement("2")) == ["1", "3", "2", "4", "2"]

    // empty array
    expect([String]().removingFirstElement("2")) == []

    // element not found
    expect(["1", "2", "3", "2", "4", "2"].removingFirstElement("5")) == ["1", "2", "3", "2", "4", "2"]
  }

  func test_removeFirstElement() {
    do {
      var array = ["hello", "world", "!"]
      array.removeFirstElement("world")
      expect(array) == ["hello", "!"]
    }

    do {
      var array = [1, 3, 2, 3, 4, 5]
      array.removeFirstElement(3)
      expect(array) == [1, 2, 3, 4, 5]
    }

    do {
      var array: [Int] = []
      array.removeFirstElement(3)
      expect(array) == []
    }

    do {
      var array = [1, 3, 2, 3, 4, 5]
      array.removeFirstElement(6)
      expect(array) == [1, 3, 2, 3, 4, 5]
    }

    do {
      var array = [1]
      array.removeFirstElement(1)
      expect(array) == []
    }
  }

  func test_firstOfType() {
    let array: [Any] = ["a", 1, true, 2]
    expect(array.first(type: Int.self)) == 1
    expect(array.first(type: NSObject.self)) != nil // got "a"
    expect(array.first(type: [Int].self)) == nil
  }

  func test_lastOfType() {
    let array: [Any] = ["a", 1, true, 2]
    expect(array.last(type: Int.self)) == 2
    expect(array.last(type: NSObject.self)) != nil // got "a"
    expect(array.last(type: [Int].self)) == nil
  }

  func test_popFirst() {
    var array: [Any] = ["a", 1]
    expect(array.popFirst() as? String) == "a"
    expect(array.popFirst() as? Int) == 1
    expect(array.popFirst()) == nil
  }

  func test_compacted() {
    do {
      let array: [Int?] = [1, 2, 3, 4, 5]
      expect(array.compacted()) == [1, 2, 3, 4, 5]
    }

    do {
      let array: [Int?] = [1, 2, nil, 4, 5, nil]
      expect(array.compacted()) == [1, 2, 4, 5]
    }

    do {
      let array: [Int?] = [nil, nil, nil, nil]
      expect(array.compacted()) == []
    }

    do {
      let array: [Int?] = []
      expect(array.compacted()) == []
    }
  }

  func test_chunked() {
    let emptyArray: [Int] = []
    expect(emptyArray.chunked(by: 0)) == []
    expect(emptyArray.chunked(by: 1)) == []

    let array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let result0 = array.chunked(by: 0)
    expect(result0.count) == 0

    let result1 = array.chunked(by: 1)
    expect(result1.count) == array.count
    expect(result1[0]) == [array[0]]
    expect(result1[1]) == [array[1]]
    expect(result1[2]) == [array[2]]
    expect(result1[3]) == [array[3]]
    expect(result1[4]) == [array[4]]
    expect(result1[5]) == [array[5]]
    expect(result1[6]) == [array[6]]
    expect(result1[7]) == [array[7]]
    expect(result1[8]) == [array[8]]

    let result2NoPartial = array.chunked(by: 2)
    expect(result2NoPartial.count) == 4
    expect(result2NoPartial[0]) == [array[0], array[1]]
    expect(result2NoPartial[1]) == [array[2], array[3]]
    expect(result2NoPartial[2]) == [array[4], array[5]]
    expect(result2NoPartial[3]) == [array[6], array[7]]

    let result2WithPartial = array.chunked(by: 2, acceptPartialResult: true)
    expect(result2WithPartial.count) == 5
    expect(result2WithPartial[0]) == [array[0], array[1]]
    expect(result2WithPartial[1]) == [array[2], array[3]]
    expect(result2WithPartial[2]) == [array[4], array[5]]
    expect(result2WithPartial[3]) == [array[6], array[7]]
    expect(result2WithPartial[4]) == [array[8]]
  }

  func test_asPairs() {
    let array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let pairs = array.asPairs()

    expect(pairs.count) == 4
    expect(pairs[0].0) == 1
    expect(pairs[0].1) == 2
    expect(pairs[1].0) == 3
    expect(pairs[1].1) == 4
    expect(pairs[2].0) == 5
    expect(pairs[2].1) == 6
    expect(pairs[3].0) == 7
    expect(pairs[3].1) == 8
  }

  func test_indexed() {
    let array = [1, 2, 3, 4, 5]

    var collectedIndices: [Int] = []
    var collectedElements: [Int] = []
    for (i, e) in array.indexed() {
      collectedIndices.append(i)
      collectedElements.append(e)
    }

    expect(collectedIndices) == [0, 1, 2, 3, 4]
    expect(collectedElements) == [1, 2, 3, 4, 5]

    collectedIndices = []
    collectedElements = []
    for (i, e) in array.indexed().lazy {
      collectedIndices.append(i)
      collectedElements.append(e)
    }

    expect(collectedIndices) == [0, 1, 2, 3, 4]
    expect(collectedElements) == [1, 2, 3, 4, 5]
  }
}
