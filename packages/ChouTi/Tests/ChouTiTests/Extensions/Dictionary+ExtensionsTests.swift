//
//  Dictionary+ExtensionsTests.swift
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

class Dictionary_ExtensionsTests: XCTestCase {

  // MARK: - Merge

  func testMerge_noDuplicate() {
    var dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["d": 4, "e": 5, "f": 6]
    let mergedDict = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6]
    dict1.merge(dict2)
    expect(dict1) == mergedDict
  }

  func testMerge_duplicate() {
    var dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["a": 4, "e": 5, "f": 6]
    let mergedDict = ["a": 4, "b": 2, "c": 3, "e": 5, "f": 6]
    dict1.merge(dict2)
    expect(dict1) == mergedDict
  }

  func testMerge_rightIsEmpty() {
    var dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = [String: Int]()
    let mergedDict = ["a": 1, "b": 2, "c": 3]
    dict1.merge(dict2)
    expect(dict1) == mergedDict
  }

  func testMerge_leftIsEmpty() {
    var dict1 = [String: Int]()
    let dict2 = ["a": 1, "b": 2, "c": 3]
    let mergedDict = ["a": 1, "b": 2, "c": 3]
    dict1.merge(dict2)
    expect(dict1) == mergedDict
  }

  func testMerging_noDuplicate() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["d": 4, "e": 5, "f": 6]
    let mergedDict = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6]
    expect(dict1.merging(dict2)) == mergedDict
  }

  func testMerging_duplicate() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["a": 4, "e": 5, "f": 6]
    let mergedDict = ["a": 4, "b": 2, "c": 3, "e": 5, "f": 6]
    expect(dict1.merging(dict2)) == mergedDict
  }

  func testMerging_rightIsEmpty() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = [String: Int]()
    expect(dict1.merging(dict2)) == dict1
  }

  func testMerging_leftIsEmpty() {
    let dict1 = [String: Int]()
    let dict2 = ["a": 1, "b": 2, "c": 3]
    expect(dict1.merging(dict2)) == dict2
  }

  func testPlusOperator_noDuplicate() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["d": 4, "e": 5, "f": 6]
    expect(dict1 + dict2) == ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6]
  }

  func testPlusOperator_duplicate() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["a": 4, "e": 5, "f": 6]
    expect(dict1 + dict2) == ["a": 4, "b": 2, "c": 3, "e": 5, "f": 6]
  }

  func testPlusOperator_rightIsNil() {
    let dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2: [String: Int]? = nil
    expect(dict1 + dict2) == dict1
  }

  func testPlusEqualOperator_noDuplicate() {
    var dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["d": 4, "e": 5, "f": 6]
    let mergedDict = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6]
    dict1 += dict2
    expect(dict1) == mergedDict
  }

  func testPlusEqualOperator_duplicate() {
    var dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2 = ["a": 4, "e": 5, "f": 6]
    let mergedDict = ["a": 4, "b": 2, "c": 3, "e": 5, "f": 6]
    dict1 += dict2
    expect(dict1) == mergedDict
  }

  func testPlusEqualOperator_rightIsNil() {
    var dict1 = ["a": 1, "b": 2, "c": 3]
    let dict2: [String: Int]? = nil
    let mergedDict = ["a": 1, "b": 2, "c": 3]
    dict1 += dict2
    expect(dict1) == mergedDict
  }

  // MARK: - Random Subset

  func testRandomSubset() {
    let dict = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5]
    var subsetSizes = Set<Int>()
    let iterations = 1000

    for _ in 0 ..< iterations {
      let subset = dict.randomSubset()

      // Test that the subset is valid
      expect(subset.count) <= dict.count
      expect(Set(subset.keys).isSubset(of: Set(dict.keys))).to(beTrue())

      // Record the subset size
      subsetSizes.insert(subset.count)
    }

    // Test that we've seen various subset sizes
    expect(subsetSizes.count) > 1
    expect(subsetSizes.contains(0)) == true // Empty subset
    expect(subsetSizes.contains(dict.count)) == true // Full set

    // Test with empty dictionary
    let emptyDict: [String: Int] = [:]
    expect(emptyDict.randomSubset()).to(beEmpty())

    // Test with single-element dictionary
    let singleDict = ["a": 1]
    var seenEmpty = false
    var seenFull = false
    for _ in 0 ..< 100 {
      let subset = singleDict.randomSubset()
      if subset.isEmpty {
        seenEmpty = true
      } else if subset.count == 1 {
        seenFull = true
      }
      if seenEmpty, seenFull {
        break
      }
    }
    expect(seenEmpty && seenFull).to(beTrue())
  }

  // MARK: - Convenient

  func testHasKeyAndHasNoKey() {
    let dict = ["a": 1, "b": 2, "c": 3]

    // Test hasKey
    expect(dict.hasKey("a")).to(beTrue())
    expect(dict.hasKey("b")).to(beTrue())
    expect(dict.hasKey("c")).to(beTrue())
    expect(dict.hasKey("d")).to(beFalse())

    // Test hasNoKey
    expect(dict.hasNoKey("a")).to(beFalse())
    expect(dict.hasNoKey("b")).to(beFalse())
    expect(dict.hasNoKey("c")).to(beFalse())
    expect(dict.hasNoKey("d")).to(beTrue())

    // Test with empty dictionary
    let emptyDict: [String: Int] = [:]
    expect(emptyDict.hasKey("a")).to(beFalse())
    expect(emptyDict.hasNoKey("a")).to(beTrue())

    // Test with nil value
    let dictWithNil = ["a": 1, "b": nil as Int?]
    expect(dictWithNil.hasKey("a")).to(beTrue())
    expect(dictWithNil.hasKey("b")).to(beTrue())
    expect(dictWithNil.hasNoKey("a")).to(beFalse())
    expect(dictWithNil.hasNoKey("b")).to(beFalse())
  }

  // MARK: - Get key for value

  func testGetKeyForValue() {
    // Test dictionary with unique values
    let dict1 = ["a": 1, "b": 2, "c": 3]

    expect(dict1[firstKeyFor: 1]) == "a"
    expect(dict1[firstKeyFor: 2]) == "b"
    expect(dict1[firstKeyFor: 3]) == "c"
    expect(dict1[firstKeyFor: 4]) == nil

    expect(dict1.allKeys(for: 1)) == ["a"]
    expect(dict1.allKeys(for: 2)) == ["b"]
    expect(dict1.allKeys(for: 3)) == ["c"]
    expect(dict1.allKeys(for: 4)) == []

    // Test dictionary with duplicate values
    let dict2 = ["a": 1, "b": 2, "c": 1, "d": 3, "e": 2]

    expect(["a", "c"].contains(dict2[firstKeyFor: 1]!)) == true // swiftlint:disable:this force_unwrapping
    expect(["b", "e"].contains(dict2[firstKeyFor: 2]!)) == true // swiftlint:disable:this force_unwrapping
    expect(dict2[firstKeyFor: 3]) == "d"
    expect(dict2[firstKeyFor: 4]) == nil

    expect(dict2.allKeys(for: 1).sorted()) == ["a", "c"].sorted()
    expect(dict2.allKeys(for: 1).count) == 2
    expect(dict2.allKeys(for: 2).sorted()) == ["b", "e"].sorted()
    expect(dict2.allKeys(for: 2).count) == 2
    expect(dict2.allKeys(for: 3)) == ["d"]
    expect(dict2.allKeys(for: 4)) == []

    // Test empty dictionary
    let emptyDict: [String: Int] = [:]
    expect(emptyDict[firstKeyFor: 1]) == nil
    expect(emptyDict.allKeys(for: 1)) == []

    // Test dictionary with non-hashable values
    let dict3 = ["a": [1, 2], "b": [2, 3], "c": [1, 2]]
    expect(["a", "c"].contains(dict3[firstKeyFor: [1, 2]]!)) == true // swiftlint:disable:this force_unwrapping
    expect(dict3[firstKeyFor: [2, 3]]) == "b"
    expect(dict3[firstKeyFor: [3, 4]]) == nil

    expect(dict3.allKeys(for: [1, 2]).sorted()) == ["a", "c"].sorted()
    expect(dict3.allKeys(for: [1, 2]).count) == 2
    expect(dict3.allKeys(for: [2, 3])) == ["b"]
    expect(dict3.allKeys(for: [3, 4])) == []
  }
}
