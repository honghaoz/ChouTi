//
//  XCTestCase+WaitTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

class XCTestCase_WaitTests: XCTestCase {

  func test() {
    wait(timeout: 0.01)

    expect(true) == true
  }
}
