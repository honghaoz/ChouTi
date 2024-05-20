//
//  Thread+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 11/5/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class Thread_ExtensionsTests: XCTestCase {

  func test_isRunningXCTest() {
    expect(Thread.current.isRunningXCTest) == true
  }

  func test_callStackSymbolsString() {
    let callStackSymbolsString = Thread.callStackSymbolsString()
    expect(callStackSymbolsString.isEmpty) == false
  }
}
