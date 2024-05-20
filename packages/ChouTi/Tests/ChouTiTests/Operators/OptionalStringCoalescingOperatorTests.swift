//
//  OptionalStringCoalescingOperatorTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class OptionalStringCoalescingOperatorTests: XCTestCase {

  func test() {

    let isNumber: Int? = 99
    expect("\(isNumber ??? "No Number")") == "99"

    let isNil: Int? = nil
    expect("\(isNil ??? "No Number")") == "No Number"
  }
}
