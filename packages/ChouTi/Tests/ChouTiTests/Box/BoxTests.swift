//
//  BoxTests.swift
//
//  Created by Honghao Zhang on 2/27/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class BoxTests: XCTestCase {

  func testBoxContainsArrayOfStrings() {
    let box = ["1", "2"].wrapInBox()
    expect(box.value) == ["1", "2"]
  }

  // Test when box is a constant in a struct
  struct TestStruct {
    let aBox: Box<Int>!
  }

  func testBoxInStruct() {
    let value = TestStruct(aBox: Box<Int>(1))

    expect(value.aBox.value, "initial value of the box") == 1

    value.aBox.value = 2
    expect(value.aBox.value, "updated value of the box") == 2
  }
}
