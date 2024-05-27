//
//  Memory+FootprintTests.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class Memory_FootprintTests: XCTestCase {

  func test_memoryFootprint() {
    let result = Memory.memoryFootprint()
    expect(result) != nil
    expect(try result.unwrap()) > 0
  }

  func test_memoryFootprintString() {
    let result = Memory.formattedMemoryFootprint()
    expect(result.contains(" MB")) == true
  }
}
