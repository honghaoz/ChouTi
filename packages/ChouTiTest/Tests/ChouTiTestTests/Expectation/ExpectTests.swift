//
//  ExpectTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/12/23.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

  func testBeGreaterThan() {
    expect(2).to(beGreaterThan(1))
    expect(1).toNot(beGreaterThan(2))
    expect(2) > 1
    expect(1) < 2
    expect((beGreaterThan(1) as BeGreaterThanExpectation<Int>).description) == "be greater than \"1\""
  }

  func testBeGreaterThanOrEqual() {
    expect(2).to(beGreaterThanOrEqual(to: 1))
    expect(2).to(beGreaterThanOrEqual(to: 2))
    expect(1).toNot(beGreaterThanOrEqual(to: 2))
    expect(2) >= 1
    expect(2) >= 2
    expect(1) < 2
    expect((beGreaterThanOrEqual(to: 1) as BeGreaterThanOrEqualExpectation<Int>).description) == "be greater than or equal to \"1\""
  }

  func testBeLessThan() {
    expect(1).to(beLessThan(2))
    expect(2).toNot(beLessThan(1))
    expect(1) < 2
    expect(2) > 1
    expect((beLessThan(2) as BeLessThanExpectation<Int>).description) == "be less than \"2\""
  }

  func testBeLessThanOrEqual() {
    expect(1).to(beLessThanOrEqual(to: 2))
    expect(1).to(beLessThanOrEqual(to: 1))
    expect(2).toNot(beLessThanOrEqual(to: 1))
    expect(1) <= 2
    expect(1) <= 1
    expect(2) > 1
    expect((beLessThanOrEqual(to: 2) as BeLessThanOrEqualExpectation<Int>).description) == "be less than or equal to \"2\""
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
