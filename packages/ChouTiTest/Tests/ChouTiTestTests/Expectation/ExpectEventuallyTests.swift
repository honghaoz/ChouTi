//
//  ExpectEventuallyTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/24/24.
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

class ExpectEventuallyTests: XCTestCase {

  func testEventuallyTrue() {
    do {
      var count = 0
      func calculate() -> Bool {
        count += 1
        return count == 3
      }
      expect(calculate()).toEventually(beTrue())
    }

    do {
      var count = 0
      func calculate() -> Bool {
        count += 1
        if count <= 3 {
          return true
        } else {
          return false
        }
      }
      expect(calculate()).toEventuallyNot(beTrue())
    }
  }

  func testEventuallyFalse() {
    do {
      var count = 0
      func calculate() -> Bool {
        count += 1
        return count == 3
      }
      expect(calculate()).toEventually(beFalse())
    }
    do {
      var count = 0
      func calculate() -> Bool {
        count += 1
        if count <= 3 {
          return false
        } else {
          return true
        }
      }
      expect(calculate()).toEventuallyNot(beFalse())
    }
  }

  func testEventuallyEqual() {
    do {
      var count = 0
      func calculate() -> Int {
        count += 1
        return count
      }
      expect(calculate()).toEventually(beEqual(to: 3))
    }
    do {
      var count = 0
      func calculate() -> Int {
        count += 1
        if count <= 3 {
          return 3
        } else {
          return 1
        }
      }
      expect(calculate()).toEventuallyNot(beEqual(to: 3))
    }
  }

  func testEventuallyIdentical() {
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

    do {
      var count = 0
      func calculate() -> Foo {
        count += 1
        return count == 3 ? foo1 : foo2
      }

      expect(calculate()).toEventually(beIdentical(to: foo1))
    }
    do {
      var count = 0
      func calculate() -> Foo {
        count += 1
        if count <= 3 {
          return foo1
        } else {
          return foo2
        }
      }

      expect(calculate()).toEventuallyNot(beIdentical(to: foo1))
    }
  }

  func testEventuallyBeEmpty() {
    var array = [1, 2, 3]
    func calculate() -> [Int] {
      array.removeLast()
      return array
    }
    expect(calculate()).toEventually(beEmpty())
  }
}
