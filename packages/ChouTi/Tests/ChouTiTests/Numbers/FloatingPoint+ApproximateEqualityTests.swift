//
//  FloatingPoint+ApproximateEqualityTests.swift
//
//  Created by Honghao Zhang on 4/3/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import ChouTi

class FloatingPoint_ApproximateEqualityTests: XCTestCase {

  func test() {
    expect(0.1.isApproximatelyEqual(to: 0.1, absoluteTolerance: 1e-5)) == true
    expect(0.1.isApproximatelyEqual(to: 0.1, absoluteTolerance: 1e-10)) == true
    expect(0.1.isApproximatelyEqual(to: 0.101, absoluteTolerance: 1e-5)) == false
    expect(0.1.isApproximatelyEqual(to: 0.101, absoluteTolerance: 1e-1)) == true
  }
}
