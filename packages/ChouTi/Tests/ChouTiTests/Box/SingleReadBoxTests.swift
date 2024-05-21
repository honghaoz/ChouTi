//
//  SingleReadBoxTests.swift
//
//  Created by Honghao Zhang on 4/2/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

import ChouTi

class SingleReadBoxTests: XCTestCase {

  func testBoolBoxDefaultValueFalse() {
    let box = SingleReadBox<Bool>(defaultValue: false)

    XCTAssertEqual(box.defaultValue, false)

    // read when no value is set
    XCTAssertEqual(box.read(), false)
    XCTAssertEqual(box.read(), false)
    XCTAssertEqual(box.read(), false)

    // set value to true and read
    box.set(true)
    XCTAssertEqual(box.read(), true)
    XCTAssertEqual(box.read(), false)
    XCTAssertEqual(box.read(), false)
  }

  func testIntBoxDefaultValueZero() {
    let box = SingleReadBox<Int>(defaultValue: 0)

    XCTAssertEqual(box.defaultValue, 0)

    // read when no value is set
    XCTAssertEqual(box.read(), 0)
    XCTAssertEqual(box.read(), 0)
    XCTAssertEqual(box.read(), 0)

    // set value to 99 and read
    box.set(99)
    XCTAssertEqual(box.read(), 99)
    XCTAssertEqual(box.read(), 0)
    XCTAssertEqual(box.read(), 0)
  }
}

//  import Nimble
//  import Quick
//
//  class SingleReadBoxTests: QuickSpec {
//
//    override func spec() {
//      describe("for a Bool box") {
//        context("when box set default value to false") {
//          var box: SingleReadBox<Bool>!
//          beforeEach {
//            box = SingleReadBox(defaultValue: false)
//          }
//
//          it("should read correct default value") {
//            expect(box.defaultValue) == false
//          }
//
//          context("when there's no value is set") {
//            it("should read correct value") {
//              expect(box.read()) == false
//              expect(box.read()) == false
//              expect(box.read()) == false
//            }
//          }
//
//          context("when set value to true") {
//            beforeEach {
//              box.set(true)
//            }
//
//            it("should read correct values") {
//              expect(box.read()) == true
//              expect(box.read()) == false
//              expect(box.read()) == false
//            }
//          }
//        }
//      }
//
//      describe("for a Int box") {
//        context("when box set default value to 0") {
//          var box: SingleReadBox<Int>!
//          beforeEach {
//            box = SingleReadBox(defaultValue: 0)
//          }
//
//          it("should read correct default value") {
//            expect(box.defaultValue) == 0
//          }
//
//          context("when there's no value is set") {
//            it("should read correct value") {
//              expect(box.read()) == 0
//              expect(box.read()) == 0
//              expect(box.read()) == 0
//            }
//          }
//
//          context("when set value to 99") {
//            beforeEach {
//              box.set(99)
//            }
//
//            it("should read correct values") {
//              expect(box.read()) == 99
//              expect(box.read()) == 0
//              expect(box.read()) == 0
//            }
//          }
//        }
//      }
//    }
//  }
