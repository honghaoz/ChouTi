//
//  Memory+MemoryWarningPublisherTests.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

#if os(macOS)

import XCTest
import ChouTiTest

import Combine
import ChouTi

class Memory_MemoryWarningPublisherTests: XCTestCase {

  func test_memoryWarningPublisher() {
    let expectation = XCTestExpectation(description: "memoryWarningPublisher")
    let memoryWarningObservationToken = Memory.memoryWarningPublisher
      .sink {
        expectation.fulfill()
      }
    _ = memoryWarningObservationToken

    Memory.triggerMemoryWarning()

    wait(for: [expectation], timeout: 1)
  }
}

#endif
