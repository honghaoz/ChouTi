//
//  Optional+AssertTests.swift
//
//  Created by Honghao Zhang on 11/5/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTi

class Optional_AssertTests: XCTestCase {

  func test_valid() {
    let number: Int? = 2
    XCTAssertEqual(number.assert() ?? 1, 2)
  }

  func test_nil() {
    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        XCTAssertEqual(message, "Unexpected nil value")
      }

      let nilNumber: Int? = nil
      XCTAssertEqual(nilNumber.assert() ?? 1, 1)

      Assert.resetTestAssertionFailureHandler()
    }

    do {
      // with metadata
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        XCTAssertEqual(message, "Unexpected nil value")
        XCTAssertEqual(metadata, ["key": "value"])
      }

      let nilNumber: Int? = nil
      XCTAssertEqual(nilNumber.assert(metadata: ["key": "value"]) ?? 1, 1)

      Assert.resetTestAssertionFailureHandler()
    }
  }
}
