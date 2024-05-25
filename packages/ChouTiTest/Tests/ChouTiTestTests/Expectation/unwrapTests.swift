//
//  unwrapTests.swift
//
//  Created by Honghao Zhang on 5/24/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class unwrapTests: XCTestCase {

  func testUnwrap() {
    let nilValue: Int? = 1
    expect(try unwrap(nilValue)) == 1
    expect(try nilValue.unwrap()) == 1

    try expect(unwrap(nilValue)) == 1
    try expect(nilValue.unwrap()) == 1
  }
}
