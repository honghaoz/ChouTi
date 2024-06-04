//
//  RuntimeErrorTests.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class RuntimeErrorTests: XCTestCase {

  func test_runtimeError() {
    do {
      let error = RuntimeError.empty
      expect(error.description) == "<empty>"
    }

    do {
      let error = RuntimeError.reason("custom error")
      expect(error.description) == "custom error"
    }

    do {
      let error = RuntimeError.error(NSError(domain: "com.chouti.error", code: 1, userInfo: nil))
      expect(error.description) == #"Error Domain=com.chouti.error Code=1 "(null)""#
    }
  }

  func test_Equatable() {
    expect(RuntimeError.empty) == RuntimeError.empty
    expect(RuntimeError.empty) != RuntimeError.reason("custom error")
    expect(RuntimeError.reason("custom error")) == RuntimeError.reason("custom error")
    expect(RuntimeError.error(NSError(domain: "com.chouti.error", code: 1, userInfo: nil))) == RuntimeError.error(NSError(domain: "com.chouti.error", code: 1, userInfo: nil))
  }
}
