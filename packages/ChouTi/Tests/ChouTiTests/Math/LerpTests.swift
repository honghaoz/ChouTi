//
//  LerpTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class LerpTests: XCTestCase {

  func testLerp() {
    // common
    XCTAssertEqual(lerp(start: 0, end: 100, t: 0.5), 50)
    XCTAssertEqual(lerp(start: 10.0, end: 20.0, t: 0.1), 11.0)
    XCTAssertEqual(lerp(start: 10.0, end: 10.0, t: 0.1), 10.0)
    // clamps
    XCTAssertEqual(lerp(start: 10.0, end: 20.0, t: -1.1), 10)
    XCTAssertEqual(lerp(start: 10.0, end: 20.0, t: 1.1), 20)
    // revered
    XCTAssertEqual(lerp(start: 20.0, end: 10.0, t: 0.1), 19.0)

    // common
    XCTAssertEqual(0.lerp(end: 100, t: 0.5), 50)
    XCTAssertEqual(10.0.lerp(end: 20.0, t: 0.1), 11.0)
    XCTAssertEqual(10.lerp(end: 10.0, t: 0.1), 10.0)
    // clamps
    XCTAssertEqual(10.lerp(end: 20.0, t: -1.1), 10)
    XCTAssertEqual(10.lerp(end: 20.0, t: 1.1), 20)
    // revered
    XCTAssertEqual(20.lerp(end: 10.0, t: 0.1), 19.0)
  }
}
