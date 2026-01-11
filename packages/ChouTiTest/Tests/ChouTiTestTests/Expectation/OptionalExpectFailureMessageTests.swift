//
//  OptionalExpectFailureMessageTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/10/26.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import ChouTiTest
import XCTest

import Foundation

class OptionalExpectFailureMessageTests: FailureCapturingTestCase {

  // MARK: - To

  func testOptional_beEmpty() {
    do {
      let expectedMessage = #"failed - expect "nil" to be empty"#
      expect(nil as [Int]?).to(beEmpty())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Array" ("nil") to be empty"#
      expect(nil as [Int]?, "Array").to(beEmpty())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "[1]" to be empty"#
      expect([1] as [Int]?).to(beEmpty())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Array" ("[1]") to be empty"#
      expect([1] as [Int]?, "Array").to(beEmpty())
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beEqual() {
    do {
      let expectedMessage = #"failed - expect "nil" to be equal to "5""#
      expect(nil as Int?).to(beEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("nil") to be equal to "5""#
      expect(nil as Int?, "Number").to(beEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "1" to be equal to "2""#
      expect(1 as Int?).to(beEqual(to: 2))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to be equal to "2""#
      expect(1 as Int?, "Number").to(beEqual(to: 2))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beGreaterThan() {
    do {
      let expectedMessage = #"failed - expect "nil" to be greater than "5""#
      expect(nil as Int?).to(beGreaterThan(5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("nil") to be greater than "5""#
      expect(nil as Int?, "Number").to(beGreaterThan(5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "1" to be greater than "5""#
      expect(1 as Int?).to(beGreaterThan(5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to be greater than "5""#
      expect(1 as Int?, "Number").to(beGreaterThan(5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "1" to be greater than "5""#
      expect(1 as Int?) > 5
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to be greater than "5""#
      expect(1 as Int?, "Number") > 5
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beGreaterThanOrEqual() {
    do {
      let expectedMessage = #"failed - expect "nil" to be greater than or equal to "5""#
      expect(nil as Int?).to(beGreaterThanOrEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("nil") to be greater than or equal to "5""#
      expect(nil as Int?, "Number").to(beGreaterThanOrEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "1" to be greater than or equal to "5""#
      expect(1 as Int?).to(beGreaterThanOrEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to be greater than or equal to "5""#
      expect(1 as Int?, "Number").to(beGreaterThanOrEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "1" to be greater than or equal to "5""#
      expect(1 as Int?) >= 5
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to be greater than or equal to "5""#
      expect(1 as Int?, "Number") >= 5
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beLessThan() {
    do {
      let expectedMessage = #"failed - expect "nil" to be less than "1""#
      expect(nil as Int?).to(beLessThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("nil") to be less than "1""#
      expect(nil as Int?, "Number").to(beLessThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "5" to be less than "1""#
      expect(5 as Int?).to(beLessThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to be less than "1""#
      expect(5 as Int?, "Number").to(beLessThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "5" to be less than "1""#
      expect(5 as Int?) < 1
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to be less than "1""#
      expect(5 as Int?, "Number") < 1
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beLessThanOrEqual() {
    do {
      let expectedMessage = #"failed - expect "nil" to be less than or equal to "1""#
      expect(nil as Int?).to(beLessThanOrEqual(to: 1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("nil") to be less than or equal to "1""#
      expect(nil as Int?, "Number").to(beLessThanOrEqual(to: 1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "5" to be less than or equal to "1""#
      expect(5 as Int?).to(beLessThanOrEqual(to: 1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to be less than or equal to "1""#
      expect(5 as Int?, "Number").to(beLessThanOrEqual(to: 1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "5" to be less than or equal to "1""#
      expect(5 as Int?) <= 1
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to be less than or equal to "1""#
      expect(5 as Int?, "Number") <= 1
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beTrue() {
    do {
      let expectedMessage = #"failed - expect "nil" to be "true""#
      expect(nil as Bool?).to(beTrue())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Boolean" ("nil") to be "true""#
      expect(nil as Bool?, "Boolean").to(beTrue())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "false" to be "true""#
      expect(false as Bool?).to(beTrue())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Boolean" ("false") to be "true""#
      expect(false as Bool?, "Boolean").to(beTrue())
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_beFalse() {
    do {
      let expectedMessage = #"failed - expect "nil" to be "false""#
      expect(nil as Bool?).to(beFalse())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Boolean" ("nil") to be "false""#
      expect(nil as Bool?, "Boolean").to(beFalse())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "true" to be "false""#
      expect(true as Bool?).to(beFalse())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Boolean" ("true") to be "false""#
      expect(true as Bool?, "Boolean").to(beFalse())
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  // MARK: - To Not

  func testOptional_toNot_beEmpty() {
    do {
      let expectedMessage = #"failed - expect "[]" to not be empty"#
      expect([] as [Int]?).toNot(beEmpty())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Array" ("[]") to not be empty"#
      expect([] as [Int]?, "Array").toNot(beEmpty())
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beEqual() {
    do {
      let expectedMessage = #"failed - expect "5" to not be equal to "5""#
      expect(5 as Int?).toNot(beEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to not be equal to "5""#
      expect(5 as Int?, "Number").toNot(beEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beGreaterThan() {
    do {
      let expectedMessage = #"failed - expect "5" to not be greater than "1""#
      expect(5 as Int?).toNot(beGreaterThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to not be greater than "1""#
      expect(5 as Int?, "Number").toNot(beGreaterThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beGreaterThanOrEqual() {
    do {
      let expectedMessage = #"failed - expect "5" to not be greater than or equal to "5""#
      expect(5 as Int?).toNot(beGreaterThanOrEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("5") to not be greater than or equal to "5""#
      expect(5 as Int?, "Number").toNot(beGreaterThanOrEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beLessThan() {
    do {
      let expectedMessage = #"failed - expect "1" to not be less than "5""#
      expect(1 as Int?).toNot(beLessThan(5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to not be less than "5""#
      expect(1 as Int?, "Number").toNot(beLessThan(5))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beLessThanOrEqual() {
    do {
      let expectedMessage = #"failed - expect "1" to not be less than or equal to "1""#
      expect(1 as Int?).toNot(beLessThanOrEqual(to: 1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Number" ("1") to not be less than or equal to "1""#
      expect(1 as Int?, "Number").toNot(beLessThanOrEqual(to: 1))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beTrue() {
    do {
      let expectedMessage = #"failed - expect "true" to not be "true""#
      expect(true as Bool?).toNot(beTrue())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Boolean" ("true") to not be "true""#
      expect(true as Bool?, "Boolean").toNot(beTrue())
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_toNot_beFalse() {
    do {
      let expectedMessage = #"failed - expect "false" to not be "false""#
      expect(false as Bool?).toNot(beFalse())
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "Boolean" ("false") to not be "false""#
      expect(false as Bool?, "Boolean").toNot(beFalse())
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  // MARK: - Expression Throws

  func testOptional_expressionThrows_to() {
    func throwingFunc() throws -> Int? {
      throw NSError(domain: "test", code: 1, userInfo: nil)
    }

    do {
      let expectedMessage = #"failed - expect not to throw error: "Error Domain=test Code=1 "(null)"""#
      expect(try throwingFunc()).to(beEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect not to throw error: "Error Domain=test Code=1 "(null)"""#
      expect(try throwingFunc()).to(beGreaterThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect not to throw error: "Error Domain=test Code=1 "(null)"""#
      expect(try throwingFunc()).to(beLessThan(10))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptional_expressionThrows_toNot() {
    func throwingFunc() throws -> Int? {
      throw NSError(domain: "test", code: 1, userInfo: nil)
    }

    do {
      let expectedMessage = #"failed - expect not to throw error: "Error Domain=test Code=1 "(null)"""#
      expect(try throwingFunc()).toNot(beEqual(to: 5))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect not to throw error: "Error Domain=test Code=1 "(null)"""#
      expect(try throwingFunc()).toNot(beGreaterThan(1))
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect not to throw error: "Error Domain=test Code=1 "(null)"""#
      expect(try throwingFunc()).toNot(beLessThan(10))
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  // MARK: - OptionalExpectation with Nil Values

  func testOptionalExpectation_beIdentical_withNil() {
    class Foo: CustomStringConvertible {
      var description: String = "Foo"
    }

    do {
      let expectedMessage = #"failed - expect "nil" to be identical to "Foo""#
      expect(nil as Foo?).to(beIdentical(to: Foo()) as BeIdenticalOptionalExpectation<Foo>)
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "FooValue" ("nil") to be identical to "Foo""#
      expect(nil as Foo?, "FooValue").to(beIdentical(to: Foo()) as BeIdenticalOptionalExpectation<Foo>)
      assertFailure(expectedMessage: expectedMessage)
    }
  }

  func testOptionalExpectation_beIdentical_nilToNil() {
    class Foo: CustomStringConvertible {
      var description: String = "Foo"
    }

    // beIdentical with both nil values should pass, so let's test the toNot case
    do {
      let expectedMessage = #"failed - expect "nil" to not be identical to nil"#
      expect(nil as Foo?).toNot(beIdentical(to: nil) as BeIdenticalOptionalExpectation<Foo>)
      assertFailure(expectedMessage: expectedMessage)
    }

    do {
      let expectedMessage = #"failed - expect "FooValue" ("nil") to not be identical to nil"#
      expect(nil as Foo?, "FooValue").toNot(beIdentical(to: nil) as BeIdenticalOptionalExpectation<Foo>)
      assertFailure(expectedMessage: expectedMessage)
    }
  }
}
