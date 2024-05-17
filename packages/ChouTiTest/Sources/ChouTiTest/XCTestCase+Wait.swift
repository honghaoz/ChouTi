//
//  XCTestCase+Wait.swift
//
//  Created by Honghao Zhang on 4/12/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest

public extension XCTestCase {

  func wait(timeout: TimeInterval) {
    assert(Thread.isMainThread)
    // _ = XCTWaiter.wait(for: [expectation(description: "wait")], timeout: timeout)
    // RunLoop.main is slightly faster than RunLoop.current
    RunLoop.main.run(until: Date(timeInterval: timeout, since: Date()))
  }
}
