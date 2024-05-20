//
//  Optional+AssertTests.swift
//
//  Created by Honghao Zhang on 11/5/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTi

class Optional_AssertTests: XCTestCase {

  func test() {
    let number: Int? = 2
    XCTAssertEqual(number.assert() ?? 1, 2)
    let nilNumber: Int? = nil
    XCTAssertEqual(nilNumber.assert() ?? 1, 1)
  }
}
