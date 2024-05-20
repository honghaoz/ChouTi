//
//  DispatchQueue+OnceTests.swift
//
//  Created by Honghao Zhang on 1/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

import XCTest

final class DispatchQueue_OnceTests: XCTestCase {

  func test() {
    var callCount = 0
    func execute() {
      DispatchQueue.once {
        callCount += 1
      }
    }

    XCTAssertEqual(callCount, 0)
    execute()
    XCTAssertEqual(callCount, 1)
    execute()
    XCTAssertEqual(callCount, 1)
    execute()
    XCTAssertEqual(callCount, 1)
  }
}
