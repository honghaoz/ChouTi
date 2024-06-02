//
//  DispatchQueue+OnceTests.swift
//
//  Created by Honghao Zhang on 1/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

final class DispatchQueue_OnceTests: XCTestCase {

  func test_once_block() {
    var callCount = 0
    func execute() {
      DispatchQueue.once {
        callCount += 1
      }
    }

    expect(callCount) == 0
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
  }

  func test_once_block_withToken() {
    var callCount = 0
    func execute() {
      DispatchQueue.once(token: "key") {
        callCount += 1
      }
    }

    expect(callCount) == 0
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1

    DispatchQueue.once(token: "key2") {
      callCount += 1
    }
    expect(callCount) == 2
  }

  func test_once_bool() {
    var callCount = 0
    func execute() {
      guard DispatchQueue.once() else {
        return
      }
      callCount += 1
    }

    expect(callCount) == 0
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
    execute()
    expect(callCount) == 1
  }

  func test_assertOnce() {
    func execute() {
      assertOnce()
    }

    execute()

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "should only call once, token: ChouTiTests/DispatchQueue+OnceTests.swift:73:17"
    }
    execute()
    Assert.resetTestAssertionFailureHandler()
  }
}
