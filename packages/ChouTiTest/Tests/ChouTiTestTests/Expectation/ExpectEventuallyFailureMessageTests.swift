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

  // MARK: - To

  func testEventuallyEmptyTimeout() {
    let expectedMessage = "failed - expect \"[1]\" to be empty eventually"
    expect([1] as [Int]).toEventually(beEmpty(), timeout: 0.05)
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyEmptyTimeout_withDescription() {
    let expectedMessage = "failed - expect \"Array\" (\"[1]\") to be empty eventually"
    expect([1] as [Int], "Array").toEventually(beEmpty(), timeout: 0.05)
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyTrueTimeout() {
    func calculate() -> Bool {
      return false
    }

    expect(calculate()).toEventually(beTrue(), timeout: 0.05)
    let expectedMessage = "failed - expect \"false\" to be \"true\" eventually"
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyTrueTimeout_withDescription() {
    func calculate() -> Bool {
      return false
    }

    expect(calculate(), "Boolean").toEventually(beTrue(), timeout: 0.05)
    let expectedMessage = "failed - expect \"Boolean\" (\"false\") to be \"true\" eventually"
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyEqualTimeout() {
    func calculate() -> Int {
      return 1
    }

    expect(calculate()).toEventually(beEqual(to: 2), timeout: 0.05)
    let expectedMessage = "failed - expect \"1\" to be equal to \"2\" eventually"
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyEqualTimeout_withDescription() {
    func calculate() -> Int {
      return 1
    }

    expect(calculate(), "Number").toEventually(beEqual(to: 2), timeout: 0.05)
    let expectedMessage = "failed - expect \"Number\" (\"1\") to be equal to \"2\" eventually"
    assertFailure(expectedMessage: expectedMessage)
  }

  // MARK: - To Not

  func testEventuallyNotEmptyTimeout() {
    let expectedMessage = "failed - expect \"[]\" to not be empty eventually"
    expect([] as [Int]).toEventuallyNot(beEmpty(), timeout: 0.05)
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyNotEmptyTimeout_withDescription() {
    let expectedMessage = "failed - expect \"Array\" (\"[]\") to not be empty eventually"
    expect([] as [Int], "Array").toEventuallyNot(beEmpty(), timeout: 0.05)
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyNotEqualTimeout() {
    func calculate() -> Int {
      return 1
    }

    expect(calculate()).toEventuallyNot(beEqual(to: 1), timeout: 0.05)
    let expectedMessage = "failed - expect \"1\" to not be equal to \"1\" eventually"
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEventuallyNotEqualTimeout_withDescription() {
    func calculate() -> Int {
      return 1
    }

    expect(calculate(), "Number").toEventuallyNot(beEqual(to: 1), timeout: 0.05)
    let expectedMessage = "failed - expect \"Number\" (\"1\") to not be equal to \"1\" eventually"
    assertFailure(expectedMessage: expectedMessage)
  }
}
