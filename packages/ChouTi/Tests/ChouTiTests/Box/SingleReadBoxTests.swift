//
//  SingleReadBoxTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/2/23.
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

import ChouTi

class SingleReadBoxTests: XCTestCase {

  func testBoolBoxDefaultValueFalse() {
    let box = SingleReadBox<Bool>(defaultValue: false)

    expect(box.defaultValue) == false

    // read when no value is set
    expect(box.read()) == false
    expect(box.read()) == false
    expect(box.read()) == false

    // set value to true and read
    box.set(true)
    expect(box.read()) == true
    expect(box.read()) == false
    expect(box.read()) == false
  }

  func testIntBoxDefaultValueZero() {
    let box = SingleReadBox<Int>(defaultValue: 0)

    expect(box.defaultValue) == 0

    // read when no value is set
    expect(box.read()) == 0
    expect(box.read()) == 0
    expect(box.read()) == 0

    // set value to 99 and read
    box.set(99)
    expect(box.read()) == 99
    expect(box.read()) == 0
    expect(box.read()) == 0
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
