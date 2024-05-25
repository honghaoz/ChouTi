//
//  OptionalExpectTests.swift
//
//  Created by Honghao Zhang on 11/12/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class OptionalExpectTests: XCTestCase {

  func testBeNil() {
    let validValue: Int? = 1
    let nilValue: Int? = nil

    expect(nilValue).to(beNil())
    expect(validValue).toNot(beNil())
    expect(nilValue) == nil
    expect(validValue) != nil

    expect((beNil() as BeNilExpectation<Int>).description) == "be nil"
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

    let nilValue: Foo? = nil
    let foo1: Foo? = Foo(value: 1)
    let foo2: Foo? = Foo(value: 2)

    expect(foo1).to(beIdentical(to: foo1))
    expect(foo1).toNot(beIdentical(to: foo2))
    expect(foo1).toNot(beIdentical(to: nilValue))
    expect(foo1) === foo1
    expect(foo1) !== foo2
    expect(foo1) !== nilValue
    expect(nilValue).to(beIdentical(to: nilValue))
    expect(nilValue).toNot(beIdentical(to: foo1))
    expect(nilValue) === nil

    expect((beIdentical(to: foo1) as BeIdenticalOptionalExpectation<Foo>).description) == "be identical to \"Foo(1)\""
    expect((beIdentical(to: nilValue) as BeIdenticalOptionalExpectation<Foo>).description) == "be identical to nil"
  }
}
