//
//  Array+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class Array_ExtensionsTests: XCTestCase {

  func testRemovingDuplicates() {
    var integers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    XCTAssertEqual(integers.removingDuplicates(), [1, 2, 3, 4, 5])

    XCTAssertEqual(integers, [1, 2, 2, 1, 3, 4, 5, 3, 4, 5])
    integers.removeDuplicates()
    XCTAssertEqual(integers, [1, 2, 3, 4, 5])
  }

  func testUnique() {
    let integers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    XCTAssertEqual(integers.removingDuplicates(), [1, 2, 3, 4, 5])
  }

  func testAllUnique() {
    let nonUniqueIntegers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    XCTAssertFalse(nonUniqueIntegers.allUnique())

    let uniqueIntegers = [1, 2, 3, 4, 5]
    XCTAssertTrue(uniqueIntegers.allUnique())

    let empty: [Int] = []
    XCTAssertTrue(empty.allUnique())
  }

  func testAsSet() {
    XCTAssertEqual(["a", "b", "c", "c"].asSet(), Set(["a", "b", "c"]))
  }

  func testAllEqual() {
    let nonEqualIntegers = [1, 2, 2, 1, 3, 4, 5, 3, 4, 5]
    XCTAssertFalse(nonEqualIntegers.allEqual())

    let equalIntegers = [1, 1, 1, 1, 1]
    XCTAssertTrue(equalIntegers.allEqual())

    let empty: [Int] = []
    XCTAssertTrue(empty.allEqual())
  }

  func removingFirstElement() {
    expect(["ni", "hao", "ma", "?"].removingFirstElement("hao")) == ["ni", "ma", "?"]
    expect(["ni", "hao", "ma", "?"].removingFirstElement("hao")) == ["ni", "ma", "?"]

    // duplicated elements
    expect(["1", "2", "3", "2", "4", "2"].removingFirstElement("2")) == ["1", "3", "2", "4", "2"]

    // empty array
    expect([String]().removingFirstElement("2")) == []

    // element not found
    expect(["1", "2", "3", "2", "4", "2"].removingFirstElement("5")) == ["1", "2", "3", "2", "4", "2"]
  }

  func testRemoveElement() {
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

  func testFirstOfType() {
    let array: [Any] = ["a", 1, true, 2]
    XCTAssertEqual(array.first(type: Int.self), 1)
    XCTAssertNotNil(array.first(type: NSObject.self)) // got "a"
    XCTAssertNil(array.first(type: [Int].self))
  }

  func testLastOfType() {
    let array: [Any] = ["a", 1, true, 2]
    XCTAssertEqual(array.last(type: Int.self), 2)
    XCTAssertNotNil(array.last(type: NSObject.self)) // got "a"
    XCTAssertNil(array.last(type: [Int].self))
  }

  func testPopFirst() {
    var array: [Any] = ["a", 1]
    XCTAssertEqual(array.popFirst() as? String, "a")
    XCTAssertEqual(array.popFirst() as? Int, 1)
    XCTAssertNil(array.popFirst())
  }

  func testCompacted() {
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

  func testChunked() {
    let emptyArray: [Int] = []
    XCTAssertEqual(emptyArray.chunked(0), [])
    XCTAssertEqual(emptyArray.chunked(1), [])

    let array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let result0 = array.chunked(0)
    XCTAssertEqual(result0.count, 0)

    let result1 = array.chunked(1)
    XCTAssertEqual(result1.count, array.count)
    XCTAssertEqual(result1[0], [array[0]])
    XCTAssertEqual(result1[1], [array[1]])
    XCTAssertEqual(result1[2], [array[2]])
    XCTAssertEqual(result1[3], [array[3]])
    XCTAssertEqual(result1[4], [array[4]])
    XCTAssertEqual(result1[5], [array[5]])
    XCTAssertEqual(result1[6], [array[6]])
    XCTAssertEqual(result1[7], [array[7]])
    XCTAssertEqual(result1[8], [array[8]])

    let result2NoPartial = array.chunked(2)
    XCTAssertEqual(result2NoPartial.count, 4)
    XCTAssertEqual(result2NoPartial[0], [array[0], array[1]])
    XCTAssertEqual(result2NoPartial[1], [array[2], array[3]])
    XCTAssertEqual(result2NoPartial[2], [array[4], array[5]])
    XCTAssertEqual(result2NoPartial[3], [array[6], array[7]])

    let result2WithPartial = array.chunked(2, acceptPartialResult: true)
    XCTAssertEqual(result2WithPartial.count, 5)
    XCTAssertEqual(result2WithPartial[0], [array[0], array[1]])
    XCTAssertEqual(result2WithPartial[1], [array[2], array[3]])
    XCTAssertEqual(result2WithPartial[2], [array[4], array[5]])
    XCTAssertEqual(result2WithPartial[3], [array[6], array[7]])
    XCTAssertEqual(result2WithPartial[4], [array[8]])
  }

  func testAsPairs() {
    let array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    let pairs = array.asPairs()

    XCTAssertEqual(pairs.count, 4)
    XCTAssertEqual(pairs[0].0, 1)
    XCTAssertEqual(pairs[0].1, 2)
    XCTAssertEqual(pairs[1].0, 3)
    XCTAssertEqual(pairs[1].1, 4)
    XCTAssertEqual(pairs[2].0, 5)
    XCTAssertEqual(pairs[2].1, 6)
    XCTAssertEqual(pairs[3].0, 7)
    XCTAssertEqual(pairs[3].1, 8)
  }

  func testIndexed() {
    let array = [1, 2, 3, 4, 5]

    var collectedIndices: [Int] = []
    var collectedElements: [Int] = []
    for (i, e) in array.indexed() {
      collectedIndices.append(i)
      collectedElements.append(e)
    }

    XCTAssertEqual(collectedIndices, [0, 1, 2, 3, 4])
    XCTAssertEqual(collectedElements, [1, 2, 3, 4, 5])

    collectedIndices = []
    collectedElements = []
    for (i, e) in array.indexed().lazy {
      collectedIndices.append(i)
      collectedElements.append(e)
    }

    XCTAssertEqual(collectedIndices, [0, 1, 2, 3, 4])
    XCTAssertEqual(collectedElements, [1, 2, 3, 4, 5])
  }
}
