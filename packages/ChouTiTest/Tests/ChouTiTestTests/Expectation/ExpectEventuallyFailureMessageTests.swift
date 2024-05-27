//
//  ExpectEventuallyFailureMessageTests.swift
//
//  Created by Honghao Zhang on 5/24/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class ExpectEventuallyFailureMessageTests: FailureCapturingTestCase {

  func testEventuallyTrueTimeout() {
    do {
      func calculate() -> Bool {
        return false
      }

      expect(calculate()).toEventually(beTrue(), timeout: 0.05)
      let expectedMessage = "failed - expect \"false\" to be \"true\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      func calculate() -> Bool {
        return true
      }

      expect(calculate()).toEventuallyNot(beTrue(), timeout: 0.05)
      let expectedMessage = #"failed - expect "true" to not be "true" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyTrueTimeout_withDescription() {
    do {
      func calculate() -> Bool {
        return false
      }

      expect(calculate(), "Boolean").toEventually(beTrue(), timeout: 0.05)
      let expectedMessage = "failed - expect \"Boolean\" (\"false\") to be \"true\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      func calculate() -> Bool {
        return true
      }

      expect(calculate(), "Boolean").toEventuallyNot(beTrue(), timeout: 0.05)
      let expectedMessage = #"failed - expect "Boolean" ("true") to not be "true" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyEqualTimeout() {
    do {
      func calculate() -> Int {
        return 1
      }

      expect(calculate()).toEventually(beEqual(to: 2), timeout: 0.05)
      let expectedMessage = #"failed - expect "1" to be equal to "2" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      expect(nil).toEventually(beEqual(to: 2), timeout: 0.05)
      let expectedMessage = #"failed - expect "nil" to be equal to "2" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func calculate() -> Int {
        return 1
      }

      expect(calculate()).toEventuallyNot(beEqual(to: 1), timeout: 0.05)
      let expectedMessage = "failed - expect \"1\" to not be equal to \"1\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      expect(nil).toEventuallyNot(beEqual(to: nil as Int?), timeout: 0.05)
      let expectedMessage = #"failed - expect "nil" to not be equal to "nil" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyEqualTimeout_withDescription() {
    do {
      func calculate() -> Int {
        return 1
      }

      expect(calculate(), "Number").toEventually(beEqual(to: 2), timeout: 0.05)
      let expectedMessage = "failed - expect \"Number\" (\"1\") to be equal to \"2\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      expect(nil, "Number").toEventually(beEqual(to: 2), timeout: 0.05)
      let expectedMessage = "failed - expect \"Number\" (\"nil\") to be equal to \"2\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func calculate() -> Int {
        return 1
      }

      expect(calculate(), "Number").toEventuallyNot(beEqual(to: 1), timeout: 0.05)
      let expectedMessage = "failed - expect \"Number\" (\"1\") to not be equal to \"1\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      expect(nil, "Number").toEventuallyNot(beEqual(to: nil as Int?), timeout: 0.05)
      let expectedMessage = "failed - expect \"Number\" (\"nil\") to not be equal to \"nil\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyApproximatelyEqualTimeout() {
    do {
      func calculate() -> Double {
        return 1.0
      }

      expect(calculate()).toEventually(beApproximatelyEqual(to: 2.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expect "1.0" to be approximately equal to "2.0 ± 1e-05" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      func calculate() -> Double? {
        return nil
      }
      expect(try calculate().unwrap()).toEventually(beApproximatelyEqual(to: 2.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expression throws error: nilValue"#
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func calculate() -> Double {
        return 1.0
      }

      expect(calculate()).toEventuallyNot(beApproximatelyEqual(to: 1.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expect "1.0" to not be approximately equal to "1.0 ± 1e-05" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      func calculate() -> Double? {
        return nil
      }
      expect(try calculate().unwrap()).toEventuallyNot(beApproximatelyEqual(to: 2.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expression throws error: nilValue"#
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyApproximatelyEqualTimeout_withDescription() {
    do {
      func calculate() -> Double {
        return 1.0
      }

      expect(calculate(), "Number").toEventually(beApproximatelyEqual(to: 2.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = "failed - expect \"Number\" (\"1.0\") to be approximately equal to \"2.0 ± 1e-05\" eventually"
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      func calculate() -> Double? {
        return nil
      }
      expect(try calculate().unwrap(), "Number").toEventually(beApproximatelyEqual(to: 2.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expression "Number" throws error: nilValue"#
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func calculate() -> Double {
        return 1.0
      }

      expect(calculate(), "Number").toEventuallyNot(beApproximatelyEqual(to: 1.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expect "Number" ("1.0") to not be approximately equal to "1.0 ± 1e-05" eventually"#
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      func calculate() -> Double? {
        return nil
      }
      expect(try calculate().unwrap(), "Number").toEventuallyNot(beApproximatelyEqual(to: 2.0, within: 1e-5), timeout: 0.05)
      let expectedMessage = #"failed - expression "Number" throws error: nilValue"#
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyEmptyTimeout() {
    do {
      let expectedMessage = "failed - expect \"[1]\" to be empty eventually"
      expect([1] as [Int]).toEventually(beEmpty(), timeout: 0.05)
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      let expectedMessage = "failed - expect \"[]\" to not be empty eventually"
      expect([] as [Int]).toEventuallyNot(beEmpty(), timeout: 0.05)
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEventuallyEmptyTimeout_withDescription() {
    do {
      let expectedMessage = "failed - expect \"Array\" (\"[1]\") to be empty eventually"
      expect([1] as [Int], "Array").toEventually(beEmpty(), timeout: 0.05)
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      let expectedMessage = "failed - expect \"Array\" (\"[]\") to not be empty eventually"
      expect([] as [Int], "Array").toEventuallyNot(beEmpty(), timeout: 0.05)
      assertFailure(expectedMessage: expectedMessage)
    }
  }
}
