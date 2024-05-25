//
//  ExpectEventuallyTests.swift
//
//  Created by Honghao Zhang on 5/24/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import Foundation

class ExpectEventuallyTests: XCTestCase {

  // MARK: - To

  func testEventuallyTrue() {
    var count = 0
    func calculate() -> Bool {
      count += 1
      return count == 3
    }
    expect(calculate()).toEventually(beTrue())
  }

  func testEventuallyFalse() {
    var count = 0
    func calculate() -> Bool {
      count += 1
      return count == 3
    }
    expect(calculate()).toEventually(beFalse())
  }

  func testEventuallyEqual() {
    var count = 0
    func calculate() -> Int {
      count += 1
      return count
    }
    expect(calculate()).toEventually(beEqual(to: 3))
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

    var count = 0
    func calculate() -> Foo {
      count += 1
      return count == 3 ? foo1 : foo2
    }

    expect(calculate()).toEventually(beIdentical(to: foo1))
  }

  func testEventuallyBeEmpty() {
    var array = [1, 2, 3]
    func calculate() -> [Int] {
      array.removeLast()
      return array
    }
    expect(calculate()).toEventually(beEmpty())
  }

  // MARK: - To Not

  func testEventuallyNotTrue() {
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

  func testEventuallyNotFalse() {
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

  func testEventuallyNotEqual() {
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

  func testEventuallyNotIdentical() {
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
