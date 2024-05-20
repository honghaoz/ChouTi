//
//  FailedExpectationTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class FailedExpectationTests: FailureCapturingTestCase {

  func testEmpty() {
    let expectedMessage = "failed - expect \"[1]\" to be empty"
    expect([1] as [Int]).to(beEmpty())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEmpty_withDescription() {
    let expectedMessage = "failed - expect \"Array\" (\"[1]\") to be empty"
    expect([1] as [Int], "Array").to(beEmpty())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEqual() {
    let expectedMessage = "failed - expect \"1\" to be equal to \"2\""
    expect(1) == 2
    assertFailure(expectedMessage: expectedMessage)
  }

  func testEqual_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"1\") to be equal to \"2\""
    expect(1, "Number") == 2
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotEqual() {
    let expectedMessage = "failed - expect \"1\" to not be equal to \"1\""
    expect(1) != 1
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotEqual_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"1\") to not be equal to \"1\""
    expect(1, "Number") != 1
    assertFailure(expectedMessage: expectedMessage)
  }

  func testTrue() {
    let expectedMessage = "failed - expect \"true\" to be equal to \"false\""
    expect(true) == false
    assertFailure(expectedMessage: expectedMessage)
  }

  func testTrue_withDescription() {
    let expectedMessage = "failed - expect \"Boolean\" (\"true\") to be equal to \"false\""
    expect(true, "Boolean") == false
    assertFailure(expectedMessage: expectedMessage)
  }

  func testFalse() {
    let expectedMessage = "failed - expect \"false\" to be equal to \"true\""
    expect(false) == true
    assertFailure(expectedMessage: expectedMessage)
  }

  func testFalse_withDescription() {
    let expectedMessage = "failed - expect \"Boolean\" (\"false\") to be equal to \"true\""
    expect(false, "Boolean") == true
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNil() {
    let expectedMessage = "failed - expect \"1\" to be nil"
    expect(Optional(1)) == nil
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNil_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"1\") to be nil"
    expect(Optional(1), "Number") == nil
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotNil() {
    let expectedMessage = "failed - expect \"nil\" to not be nil"
    expect(nil as Int?) != nil
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotNil_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"nil\") to not be nil"
    expect(nil as Int?, "Number") != nil
    assertFailure(expectedMessage: expectedMessage)
  }

  func testUnwrap_noDescription() {
    let expectedMessage = "failed - expect a non-nil value of type Int"
    do {
      _ = try (nil as Int?).unwrap()
    } catch {
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testUnwrap_withDescription() {
    let expectedMessage = "failed - expect a non-nil value of \"Number\" (Int)"
    do {
      _ = try (nil as Int?).unwrap(description: "Number")
    } catch {
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testThrow() {
    func noThrowErrorFunc() throws -> Int {
      1
    }

    let expectedMessage = "failed - expect to throw an error"
    expect(try noThrowErrorFunc()).to(throwSomeError())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testThrow_withDescription() {
    func noThrowErrorFunc() throws -> Int {
      1
    }

    let expectedMessage = "failed - expect \"noThrowFunc\" to throw an error"
    expect(try noThrowErrorFunc(), "noThrowFunc").to(throwSomeError())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotThrow() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1
    }

    let expectedMessage = "failed - expect \"error1\" to not be a type of \"Error\""
    expect(try throwError1Func()).toNot(throwSomeError())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotThrow_withDescription() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1
    }

    let expectedMessage = "failed - expect \"ThrowErrorFunc\" error (\"error1\") to not be a type of \"Error\""
    expect(try throwError1Func(), "ThrowErrorFunc").toNot(throwSomeError())
    assertFailure(expectedMessage: expectedMessage)
  }
}
