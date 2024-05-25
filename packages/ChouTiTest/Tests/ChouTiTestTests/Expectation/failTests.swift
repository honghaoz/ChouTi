//
//  failTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

class failTests: FailureCapturingTestCase {

  func test() {
    let expectedMessage = "Test failure message"

    fail(expectedMessage)

    assertFailureContains(expectedMessage: expectedMessage)
  }
}
