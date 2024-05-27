//
//  HashableBoxTests.swift
//
//  Created by Honghao Zhang on 2/27/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

import ChouTi

class HashableBoxTests: XCTestCase {

  func testHashableBox_Int() {
    let box = HashableBox(key: 1, "abc")
    let box2 = HashableBox(key: 1, "def")
    XCTAssertEqual(box, box2, "boxes with the same key should be equal")

    XCTAssertEqual(box.hashValue, box.hashValue)

    XCTAssertEqual(box.key, 1)
    XCTAssertEqual(box.value, "abc")
  }

  func testHashableBox_String() {
    let box = HashableBox(key: "key2", "abc")
    let box2 = HashableBox(key: "key2", "def")
    XCTAssertEqual(box, box2, "boxes with the same key should be equal")

    XCTAssertEqual(box.key, "key2")
    XCTAssertEqual(box.value, "abc")
  }

  func test_key() {
    let box = HashableBox.key(1, "abc")
    let box2 = HashableBox.key(1, "def")
    XCTAssertEqual(box, box2, "boxes with the same key should be equal")

    XCTAssertEqual(box.key, 1)
    XCTAssertEqual(box.value, "abc")
  }

  func test_unique_MachTimeId() {
    let box = HashableBox<MachTimeId, String>.unique("abc")
    let box2 = HashableBox<MachTimeId, String>.unique("def")
    XCTAssertNotEqual(box, box2, "unique boxes should not be equal")
  }

  func test_unique_String() {
    let box = HashableBox<String, String>.unique("abc")
    let box2 = HashableBox<String, String>.unique("def")
    XCTAssertNotEqual(box, box2, "unique boxes should not be equal")
  }

  func test_fixed_AnyHashable() {
    let box = HashableBox<AnyHashable, String>.fixed("abc")
    let box2 = HashableBox<AnyHashable, String>.fixed("def")
    XCTAssertEqual(box, box2, "fixed boxes should be equal")
  }

  func test_unique_AnyHashable() {
    let box = HashableBox<AnyHashable, String>.unique("abc")
    let box2 = HashableBox<AnyHashable, String>.unique("def")
    XCTAssertNotEqual(box, box2, "unique boxes should not be equal")
  }
}
