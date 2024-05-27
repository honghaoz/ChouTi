//
//  ExpectFailureMessageTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class ExpectFailureMessageTests: FailureCapturingTestCase {

  // MARK: - Non Optional

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

  func testEqual() {
    do {
      let expectedMessage = "failed - expect \"1\" to be equal to \"2\""
      expect(1) == 2
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "nil" to be equal to "6""#
      expect(nil as Int?).to(beEqual(to: 6))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = "failed - expect \"1\" to not be equal to \"1\""
      expect(1) != 1
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testEqual_withDescription() {
    do {
      let expectedMessage = "failed - expect \"Number\" (\"1\") to be equal to \"2\""
      expect(1, "Number") == 2
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      let expectedMessage = "failed - expect \"Number\" (\"1\") to not be equal to \"1\""
      expect(1, "Number") != 1
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testBeApproximatelyEqual() {
    let expectedMessage = "failed - expect \"1.1\" to be approximately equal to \"1.2 ± 0.01\""
    expect(1.1).to(beApproximatelyEqual(to: 1.2, within: 0.01))
    assertFailure(expectedMessage: expectedMessage)
  }

  func testBeApproximatelyEqual_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"1.1\") to be approximately equal to \"1.2 ± 0.01\""
    expect(1.1, "Number").to(beApproximatelyEqual(to: 1.2, within: 0.01))
    assertFailure(expectedMessage: expectedMessage)
  }

  func testGreaterThan() {
    let expectedMessage = "failed - expect \"1\" to be greater than \"2\""
    expect(1) > 2
    assertFailure(expectedMessage: expectedMessage)
  }

  func testGreaterThan_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"1\") to be greater than \"2\""
    expect(1, "Number") > 2
    assertFailure(expectedMessage: expectedMessage)
  }

  func testGreaterThanOrEqual() {
    let expectedMessage = "failed - expect \"1\" to be greater than or equal to \"2\""
    expect(1) >= 2
    assertFailure(expectedMessage: expectedMessage)
  }

  func testGreaterThanOrEqual_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"1\") to be greater than or equal to \"2\""
    expect(1, "Number") >= 2
    assertFailure(expectedMessage: expectedMessage)
  }

  func testLessThan() {
    let expectedMessage = "failed - expect \"2\" to be less than \"1\""
    expect(2) < 1
    assertFailure(expectedMessage: expectedMessage)
  }

  func testLessThan_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"2\") to be less than \"1\""
    expect(2, "Number") < 1
    assertFailure(expectedMessage: expectedMessage)
  }

  func testLessThanOrEqual() {
    let expectedMessage = "failed - expect \"2\" to be less than or equal to \"1\""
    expect(2) <= 1
    assertFailure(expectedMessage: expectedMessage)
  }

  func testLessThanOrEqual_withDescription() {
    let expectedMessage = "failed - expect \"Number\" (\"2\") to be less than or equal to \"1\""
    expect(2, "Number") <= 1
    assertFailure(expectedMessage: expectedMessage)
  }

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

  // MARK: - Optional

  func testNil() {
    do {
      let expectedMessage = #"failed - expect "1" to be nil"#
      expect(Optional(1)) == nil
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      class Foo: CustomStringConvertible {
        var description: String = "Foo"
      }
      let expectedMessage = #"failed - expect "nil" to be identical to "Foo""#
      expect(nil as Foo?).to(beIdentical(to: Foo()))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "nil" to not be nil"#
      expect(nil as Int?) != nil
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testNil_withDescription() {
    do {
      let expectedMessage = #"failed - expect "Number" ("1") to be nil"#
      expect(Optional(1), "Number") == nil
      assertFailure(expectedMessage: expectedMessage)
    }
    do {
      class Foo: CustomStringConvertible {
        var description: String = "Foo"
      }
      let expectedMessage = #"failed - expect "FooNil" ("nil") to be identical to "Foo""#
      expect(nil as Foo?, "FooNil").to(beIdentical(to: Foo()))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("nil") to not be nil"#
      expect(nil as Int?, "Number") != nil
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  // MARK: - Throw Error

  func testThrowEquatableError() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum BarError: Swift.Error {
      case error1
      case error2
    }

    do {
      func noThrowErrorFunc() throws -> Int {
        1
      }

      let expectedMessage = #"failed - expect to throw an error"#
      expect(try noThrowErrorFunc()).to(throwError(FooError.error1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwFooError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "error1" to be "error2""#
      expect(try throwFooError1Func()).to(throwError(FooError.error2))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwFooError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "error1" to be a type of "BarError""#
      expect(try throwFooError1Func()).to(throwError(BarError.error1))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testThrowEquatableError_withDescription() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum BarError: Swift.Error {
      case error1
      case error2
    }

    do {
      func noThrowErrorFunc() throws -> Int {
        1
      }

      let expectedMessage = #"failed - expect "noThrowErrorFunc" to throw an error"#
      expect(try noThrowErrorFunc(), "noThrowErrorFunc").to(throwError(FooError.error1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwFooError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "throwFooError1Func"'s thrown error ("error1") to be "error2""#
      expect(try throwFooError1Func(), "throwFooError1Func").to(throwError(FooError.error2))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwFooError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "throwFooError1Func"'s thrown error ("error1") to be a type of "BarError""#
      expect(try throwFooError1Func(), "throwFooError1Func").to(throwError(BarError.error1))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testThrowNonEquatableError() {
    enum FooError: Swift.Error {
      case error1(String)
      case error2(String)
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1("foo")
    }

    let expectedMessage = #"failed - expect "error1("foo")" to be "error2("foo")""#
    expect(try throwError1Func()).to(throwError(FooError.error2("foo"), isErrorMatched: { _, _ in false }))
    assertFailure(expectedMessage: expectedMessage)
  }

  func testThrowNonEquatableError_withDescription() {
    enum FooError: Swift.Error {
      case error1(String)
      case error2(String)
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1("foo")
    }

    let expectedMessage = #"failed - expect "ThrowErrorFunc"'s thrown error ("error1("foo")") to be "error2("foo")""#
    expect(try throwError1Func(), "ThrowErrorFunc").to(throwError(FooError.error2("foo"), isErrorMatched: { _, _ in false }))
    assertFailure(expectedMessage: expectedMessage)
  }

  func testThrowErrorType() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum FooError2: Swift.Error {
      case error1
      case error2
    }

    do {
      func noThrowErrorFunc() throws -> Int {
        1
      }

      let expectedMessage = #"failed - expect to throw an error"#
      expect(try noThrowErrorFunc()).to(throwErrorOfType(FooError.self))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "error1" to be a type of "FooError2""#
      expect(try throwError1Func()).to(throwErrorOfType(FooError2.self))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testThrowErrorType_withDescription() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum FooError2: Swift.Error {
      case error1
      case error2
    }

    do {
      func noThrowErrorFunc() throws -> Int {
        1
      }

      let expectedMessage = #"failed - expect "noThrowErrorFunc" to throw an error"#
      expect(try noThrowErrorFunc(), "noThrowErrorFunc").to(throwErrorOfType(FooError.self))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "ThrowErrorFunc"'s thrown error ("error1") to be a type of "FooError2""#
      expect(try throwError1Func(), "ThrowErrorFunc").to(throwErrorOfType(FooError2.self))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testThrowAnError() {
    func noThrowErrorFunc() throws -> Int {
      1
    }

    let expectedMessage = "failed - expect to throw an error"
    expect(try noThrowErrorFunc()).to(throwAnError())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testThrowAnError_withDescription() {
    func noThrowErrorFunc() throws -> Int {
      1
    }

    let expectedMessage = "failed - expect \"noThrowFunc\" to throw an error"
    expect(try noThrowErrorFunc(), "noThrowFunc").to(throwAnError())
    assertFailure(expectedMessage: expectedMessage)
  }

  // MARK: - Not Throw Error

  func testNotThrowEquatableError() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum BarError: Swift.Error {
      case error1
      case error2
    }

    func throwFooError1Func() throws -> Int {
      throw FooError.error1
    }

    do {
      let expectedMessage = #"failed - expect "error1" to not be "error1""#
      expect(try throwFooError1Func()).toNot(throwError(FooError.error1))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testNotThrowEquatableError_withDescription() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    enum BarError: Swift.Error {
      case error1
      case error2
    }

    func throwFooError1Func() throws -> Int {
      throw FooError.error1
    }

    let expectedMessage = #"failed - expect "throwFooError1Func"'s thrown error ("error1") to not be "error1""#
    expect(try throwFooError1Func(), "throwFooError1Func").toNot(throwError(FooError.error1))
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotThrowErrorType() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    do {
      func noThrowErrorFunc() throws -> Int {
        1
      }

      let expectedMessage = #"failed - expect to throw an error"#
      expect(try noThrowErrorFunc()).to(throwErrorOfType(FooError.self))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwFooError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "error1" to not be a type of "FooError""#
      expect(try throwFooError1Func()).toNot(throwErrorOfType(FooError.self))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testNotThrowErrorType_withDescription() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    do {
      func noThrowErrorFunc() throws -> Int {
        1
      }

      let expectedMessage = #"failed - expect "noThrowErrorFunc" to throw an error"#
      expect(try noThrowErrorFunc(), "noThrowErrorFunc").to(throwErrorOfType(FooError.self))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      func throwFooError1Func() throws -> Int {
        throw FooError.error1
      }

      let expectedMessage = #"failed - expect "throwFooError1Func"'s thrown error ("error1") to not be a type of "FooError""#
      expect(try throwFooError1Func(), "throwFooError1Func").toNot(throwErrorOfType(FooError.self))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testNotThrowAnError() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1
    }

    let expectedMessage = "failed - expect to not throw an error, but got: error1"
    expect(try throwError1Func()).toNot(throwAnError())
    assertFailure(expectedMessage: expectedMessage)
  }

  func testNotThrowAnError_withDescription() {
    enum FooError: Swift.Error {
      case error1
      case error2
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1
    }

    let expectedMessage = #"failed - expect "ThrowErrorFunc" to not throw an error, but got: error1"#
    expect(try throwError1Func(), "ThrowErrorFunc").toNot(throwAnError())
    assertFailure(expectedMessage: expectedMessage)
  }

  // MARK: - Unwrap

  func testUnwrap_noDescription() {
    let expectedMessage = "failed - expect a non-nil value of type Int"
    do {
      _ = try (nil as Int?).unwrap()
    } catch {
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testUnwrap_withDescription() {
    let expectedMessage = #"failed - expect a non-nil value of "Number" (Int)"#
    do {
      _ = try (nil as Int?).unwrap(description: "Number")
    } catch {
      assertFailure(expectedMessage: expectedMessage)
    }
  }
}
