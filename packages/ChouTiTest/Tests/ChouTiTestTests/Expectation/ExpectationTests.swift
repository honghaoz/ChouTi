//
//  ExpectationTests.swift
//
//  Created by Honghao Zhang on 11/12/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class ExpectationTests: XCTestCase {

  func testBeTrue() {
    expect(1 == 1).to(beTrue())
    expect(1 != 1).toNot(beTrue())
    expect(1 == 1) == true
    expect(1 != 1) == false
    expect(beTrue().description) == "be \"true\""
  }

  func testBeFalse() {
    expect(1 != 1).to(beFalse())
    expect(1 == 1).toNot(beFalse())
    expect(1 != 1) == false
    expect(1 == 1) == true
    expect(beFalse().description) == "be \"false\""
  }

  func testBeEqual() {
    expect(1).to(beEqual(to: 1))
    expect(1).toNot(beEqual(to: 2))
    expect(1) == 1
    expect(1) != 2
    expect((beEqual(to: 1) as BeEqualExpectation<Int>).description) == "be equal to \"1\""
  }

  func testBeIdentical() {
    class Foo: CustomStringConvertible {
      let value: Int

      init(value: Int) {
        self.value = value
      }

      var description: String {
        "Foo(\(value))"
      }
    }

    let foo1 = Foo(value: 1)
    let foo2 = Foo(value: 2)

    expect(foo1).to(beIdentical(to: foo1))
    expect(foo1).toNot(beIdentical(to: foo2))
    expect(foo1) === foo1
    expect(foo1) !== foo2

    expect((beIdentical(to: foo1) as BeIdenticalExpectation<Foo>).description) == "be identical to \"Foo(1)\""
  }

  func testBeEmpty() {
    expect([] as [Int]).to(beEmpty())
    expect([1] as [Int]).toNot(beEmpty())
    expect((beEmpty() as BeEmptyExpectation<[Int]>).description) == "be empty"
  }

  func testThrowEquatableError() {
    enum FooError: Swift.Error, Equatable {
      case error1
      case error2
    }

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1
    }

    expect(try throwError1Func()).to(throwError(FooError.error1))
    expect(try throwError1Func()).toNot(throwError(FooError.error2))

    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error1))
    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error2))
  }

  func testThrowNonEquatableError() {
    enum FooError: Swift.Error {
      case error1(String)
      case error2(String)
    }

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1("foo")
    }

    expect(try throwError1Func()).to(
      throwError(FooError.error1("foo"), isErrorMatched: { expectedError, thrownError in
        switch (expectedError, thrownError) {
        case (.error1(let string1), .error1(let string2)):
          return string1 == string2
        default:
          return false
        }
      })
    )
    expect(try throwError1Func()).toNot(
      throwError(FooError.error2("foo"), isErrorMatched: { expectedError, thrownError in
        switch (expectedError, thrownError) {
        case (.error2(let string1), .error2(let string2)):
          return string1 != string2
        default:
          return false
        }
      })
    )
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

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwError1Func() throws -> Int {
      throw FooError.error1
    }

    expect(try throwError1Func()).to(throwErrorOfType(FooError.self))
    expect(try throwError1Func()).toNot(throwErrorOfType(FooError2.self))

    expect(try throwError1Func()).toNot(throwErrorOfType(FooError2.self))
    expect(try noThrowErrorFunc()).toNot(throwErrorOfType(FooError.self))
  }

  func testThrowSomeError() {
    enum SomeError: Swift.Error, Equatable {
      case error
    }

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwError1Func() throws -> Int {
      throw SomeError.error
    }

    expect(try throwError1Func()).to(throwSomeError())
    expect(try noThrowErrorFunc()).toNot(throwSomeError())
  }

  func testUnwrap() {
    let nilValue: Int? = 1
    expect(try unwrap(nilValue)) == 1
    expect(try nilValue.unwrap()) == 1

    try expect(unwrap(nilValue)) == 1
    try expect(nilValue.unwrap()) == 1
  }
}
