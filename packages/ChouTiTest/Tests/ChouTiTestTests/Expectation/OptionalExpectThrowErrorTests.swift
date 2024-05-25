//
//  OptionalExpectThrowErrorTests.swift
//
//  Created by Honghao Zhang on 5/24/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class OptionalExpectThrowErrorTests: XCTestCase {

  func testThrowError() {
    enum FooError: Swift.Error, Equatable {
      case error1
      case error2
    }

    func noThrowErrorFunc() throws -> Int? {
      1
    }

    func throwError1Func() throws -> Int? {
      throw FooError.error1
    }

    expect(try throwError1Func()).to(throwError(FooError.error1))
    expect(try throwError1Func()).toNot(throwError(FooError.error2))

    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error1))
    expect(try noThrowErrorFunc()).toNot(throwError(FooError.error2))
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

    func noThrowErrorFunc() throws -> Int? {
      1
    }

    func throwError1Func() throws -> Int? {
      throw FooError.error1
    }

    expect(try throwError1Func()).to(throwErrorOfType(FooError.self))
    expect(try throwError1Func()).toNot(throwErrorOfType(FooError2.self))

    expect(try throwError1Func()).toNot(throwErrorOfType(FooError2.self))
    expect(try noThrowErrorFunc()).toNot(throwErrorOfType(FooError.self))
  }
}
