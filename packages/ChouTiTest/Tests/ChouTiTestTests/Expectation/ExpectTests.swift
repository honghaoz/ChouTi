//
//  ExpectTests.swift
//
//  Created by Honghao Zhang on 11/12/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class ExpectTests: XCTestCase {

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

  func testBeApproximatelyEqual() {
    expect(1.0).to(beApproximatelyEqual(to: 1.0, within: 0.1))
    expect(1.0).to(beApproximatelyEqual(to: 1.2, within: 0.2))
    expect(1.0).toNot(beApproximatelyEqual(to: 1.1, within: 0.01))
    expect(1).to(beApproximatelyEqual(to: 1.001, within: 1e-3))
    expect(1).toNot(beApproximatelyEqual(to: 1.001, within: 1e-4))
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

}
