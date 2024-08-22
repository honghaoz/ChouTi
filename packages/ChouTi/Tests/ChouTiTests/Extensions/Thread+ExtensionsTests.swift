//
//  Thread+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 11/5/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class Thread_ExtensionsTests: XCTestCase {

  func test_isRunningXCTest() {
    expect(Thread.isRunningXCTest) == true
  }

  func test_isRunningXCTest_withNonStringKey() {
    let mockThreadDictionary: NSDictionary = [
      123: "Some value", // Non-string key
    ]

    expect(Thread._isRunningXCTest(threadDictionary: mockThreadDictionary)) == false
  }

  func test_callStackSymbolsString() {
    let callStackSymbolsString = Thread.callStackSymbolsString()
    expect(callStackSymbolsString.isEmpty) == false
  }
}
