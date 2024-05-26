//
//  ExpectThrowErrorTests.swift
//
//  Created by Honghao Zhang on 5/24/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class ExpectThrowErrorTests: XCTestCase {

  func testThrowEquatableError() {
    enum FooError: Swift.Error, Equatable {
      case error1
      case error2
    }

    enum BarError: Swift.Error, Equatable {
      case error1
      case error2
    }

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwFooError1Func() throws -> Int {
      throw FooError.error1
    }

    func throwFooError1OptionalFunc() throws -> Int? {
      throw FooError.error1
    }

    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error1))
    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error2))
    expect(try noThrowErrorFunc()).toNot(throwError(BarError.error1))
    expect(try noThrowErrorFunc()).toNot(throwError(BarError.error2))

    expect(try throwFooError1Func()).to(throwError(FooError.error1))
    expect(try throwFooError1Func()).toNot(throwError(FooError.error2))
    expect(try throwFooError1Func()).toNot(throwError(BarError.error1))
    expect(try throwFooError1Func()).toNot(throwError(BarError.error2))

    expect(try throwFooError1Func()).to(throwError(FooError.error1))
    expect(try throwFooError1OptionalFunc()).toNot(throwError(FooError.error2))
    expect(try throwFooError1OptionalFunc()).toNot(throwError(BarError.error1))
    expect(try throwFooError1OptionalFunc()).toNot(throwError(BarError.error2))
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

    enum BarError: Swift.Error {
      case error1
      case error2
    }

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwFooError1Func() throws -> Int {
      throw FooError.error1
    }

    expect(try throwFooError1Func()).to(throwErrorOfType(FooError.self))
    expect(try throwFooError1Func()).to(throwErrorOfType(Swift.Error.self))
    expect(try throwFooError1Func()).toNot(throwErrorOfType(BarError.self))

    expect(try noThrowErrorFunc()).toNot(throwErrorOfType(FooError.self))
    expect(try noThrowErrorFunc()).toNot(throwErrorOfType(BarError.self))
    expect(try noThrowErrorFunc()).toNot(throwErrorOfType(Swift.Error.self))
  }

  func testThrowAnError() {
    enum FooError: Swift.Error, Equatable {
      case error
    }

    func noThrowErrorFunc() throws -> Int {
      1
    }

    func throwFooError1Func() throws -> Int {
      throw FooError.error
    }

    expect(try throwFooError1Func()).to(throwAnError())
    expect(try noThrowErrorFunc()).toNot(throwAnError())
  }
}
