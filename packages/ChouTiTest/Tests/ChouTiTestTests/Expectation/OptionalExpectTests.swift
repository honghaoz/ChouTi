//
//  OptionalExpectTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/12/23.
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

class OptionalExpectTests: XCTestCase {

  func test_beNil() {
    let validValue: Int? = 1
    let nilValue: Int? = nil

    expect(nilValue).to(beNil())
    expect(validValue).toNot(beNil())
    expect(nilValue) == nil
    expect(validValue) != nil
  }

  func test_beNil_Any() {
    let validValue: Any? = 1
    let nilValue: Any? = nil

    expect(nilValue).to(beNil())
    expect(validValue).toNot(beNil())
    expect(nilValue) == nil
    expect(validValue) != nil
  }

  func test_beIdentical() {
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

  func test_beEmpty() {
    let nonEmptyValue: [Int]? = [1]
    let emptyValue: [Int]? = []
    let nilValue: [Int]? = nil

    expect(nonEmptyValue).toNot(beEmpty())
    expect(emptyValue).to(beEmpty())
    expect(nilValue).toNot(beEmpty())
  }

  func test_beEqual() {
    let value: Int? = 1
    let nilValue: Int? = nil

    expect(value).to(beEqual(to: 1))
    expect(value).toNot(beEqual(to: 2))

    expect(value) == 1
    expect(value) != 2

    expect(nilValue).toNot(beEqual(to: 1))
    expect(nilValue).toNot(beEqual(to: 2))

    expect(nilValue) == nil
    expect(nilValue) != 1
  }

  func test_beTrue() {
    let value: Bool? = true
    let nilValue: Bool? = nil

    expect(value).to(beTrue())
    expect(value).toNot(beFalse())
    expect(nilValue).toNot(beTrue())

    expect(value) == true
    expect(value) != false
    expect(nilValue) == nil
    expect(nilValue) != true
  }

  func test_beFalse() {
    let value: Bool? = false
    let nilValue: Bool? = nil

    expect(value).to(beFalse())
    expect(value).toNot(beTrue())
    expect(nilValue).toNot(beFalse())

    expect(value) == false
    expect(value) != true
    expect(nilValue) == nil
    expect(nilValue) != false
  }

  func test_beGreaterThan() {
    let value: Int? = 2
    let nilValue: Int? = nil

    expect(value).to(beGreaterThan(1))
    expect(value).toNot(beGreaterThan(2))
    expect(nilValue).toNot(beGreaterThan(1))

    expect(value) > 1
    expect(value) <= 2
  }

  func test_beGreaterThanOrEqual() {
    let value: Int? = 2
    let nilValue: Int? = nil

    expect(value).to(beGreaterThanOrEqual(to: 1))
    expect(value).to(beGreaterThanOrEqual(to: 2))
    expect(value).toNot(beGreaterThanOrEqual(to: 3))
    expect(nilValue).toNot(beGreaterThanOrEqual(to: 1))

    expect(value) >= 1
    expect(value) >= 2
    expect(value) < 3
  }

  func test_beLessThan() {
    let value: Int? = 1
    let nilValue: Int? = nil

    expect(value).to(beLessThan(2))
    expect(value).toNot(beLessThan(1))
    expect(nilValue).toNot(beLessThan(2))

    expect(value) < 2
    expect(value) >= 1
    expect(nilValue).toNot(beLessThan(2))
  }

  func test_beLessThanOrEqual() {
    let value: Int? = 1
    let nilValue: Int? = nil

    expect(value).to(beLessThanOrEqual(to: 2))
    expect(value).to(beLessThanOrEqual(to: 1))
    expect(value).toNot(beLessThanOrEqual(to: 0))
    expect(nilValue).toNot(beLessThanOrEqual(to: 2))

    expect(value) <= 2
    expect(value) <= 1
    expect(value) > 0
  }
}
