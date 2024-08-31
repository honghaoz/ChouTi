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

  func testBeNil() {
    let validValue: Int? = 1
    let nilValue: Int? = nil

    expect(nilValue).to(beNil())
    expect(validValue).toNot(beNil())
    expect(nilValue) == nil
    expect(validValue) != nil
  }

  func testBeNil_Any() {
    let validValue: Any? = 1
    let nilValue: Any? = nil

    expect(nilValue).to(beNil())
    expect(validValue).toNot(beNil())
    expect(nilValue) == nil
    expect(validValue) != nil
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
