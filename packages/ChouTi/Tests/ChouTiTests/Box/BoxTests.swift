//
//  BoxTests.swift
//
//  Created by Honghao Zhang on 2/27/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class BoxTests: XCTestCase {

  func testBoxContainsArrayOfStrings() {
    let box = ["1", "2"].wrapInBox()
    XCTAssertEqual(box.value, ["1", "2"])
  }

  // Test when box is a constant in a struct
  struct TestStruct {
    let aBox: Box<Int>!
  }

  func testBoxInStruct() {
    let value = TestStruct(aBox: Box<Int>(1))

    XCTAssertEqual(value.aBox.value, 1, "initial value of the box should be 1")

    value.aBox.value = 2
    XCTAssertEqual(value.aBox.value, 2, "updated value of the box should be 2")
  }
}
