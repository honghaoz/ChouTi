//
//  OptionalBoxTests.swift
//
//  Created by Honghao Zhang on 2/27/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class OptionalBoxTests: XCTestCase {

  func test_whenNotSet() {
    let box: OptionalBox<Int> = .notSet

    expect(box.value) == nil
    expect(box.isNotSet) == true
    expect(box.hasValue) == false

    expect(box.asAny().isNotSet) == true

    expect(box.description) == "notSet"

    var box2: OptionalBox<Int> = .notSet
    expect(box) == box2

    box2 = .none
    expect(box) != box2

    box2 = .some(200)
    expect(box) != box2

    expect(box2.description) == "some(200)"
  }

  func test_whenNone() {
    let box: OptionalBox<Int> = .none

    expect(box.value) == nil
    expect(box.isNotSet) == false
    expect(box.hasValue) == true

    expect(box.asAny().isNotSet) == false
    expect(box.asAny().hasValue) == true

    expect(box.description) == "none"

    var box2: OptionalBox<Int> = .notSet
    expect(box) != box2

    box2 = .none
    expect(box) == box2

    box2 = .some(200)
    expect(box) != box2

    expect(box2.description) == "some(200)"
  }

  func test_whenSome() {
    var box: OptionalBox<Int> = .some(101)

    expect(box.value) == 101
    expect(box.isNotSet) == false
    expect(box.hasValue) == true

    expect(box.asAny().isNotSet) == false
    expect(box.asAny().hasValue) == true

    box = (101 as Int?).wrapIntoOptionalBox()
    expect(box.value) == 101

    expect(box.description) == "some(101)"

    var box2: OptionalBox<Int> = .notSet
    expect(box) != box2

    box2 = .none
    expect(box) != box2

    box2 = .some(101)
    expect(box) == box2

    box2 = .some(102)
    expect(box) != box2

    expect(box2.description) == "some(102)"
  }

  func test_wrap() {
    let box: OptionalBox<Int> = .wrap(101)
    expect(box.value) == 101
    expect(box.isNotSet) == false
    expect(box.hasValue) == true

    expect(box.description) == "some(101)"

    let box2: OptionalBox<Int> = .wrap(nil)
    expect(box2.value) == nil
    expect(box2.isNotSet) == false
    expect(box2.hasValue) == true

    expect(box2.description) == "none"
  }
}

//  import Nimble
//  import Quick
//
//  class OptionalBoxTests: QuickSpec {
//
//    override func spec() {
//      describe("for an OptionalBox") {
//        var box: OptionalBox<Int>!
//        context("when value is notSet") {
//          beforeEach {
//            box = .notSet
//          }
//
//          it("should return nil when unwraps") {
//            expect(box.value as Int?) == nil
//          }
//
//          it("should return correct value for isNotSet") {
//            expect(box.isNotSet) == true
//          }
//
//          it("should return correct value for hasValue") {
//            expect(box.hasValue) == false
//          }
//
//          it("should return any box") {
//            expect(box.asAny().isNotSet) == true
//          }
//
//          context("should compare") {
//            var box2: OptionalBox<Int>!
//            context("when another value is notSet") {
//              beforeEach {
//                box2 = .notSet
//              }
//
//              it("should be equal") {
//                expect(box) == box2
//              }
//            }
//
//            context("when another value is none") {
//              beforeEach {
//                box2 = OptionalBox<Int>.none
//              }
//
//              it("should be not equal") {
//                expect(box) != box2
//              }
//            }
//
//            context("when another value is some") {
//              beforeEach {
//                box2 = OptionalBox<Int>.some(200)
//              }
//
//              it("should be not equal") {
//                expect(box) != box2
//              }
//            }
//          }
//        }
//
//        context("when value is none") {
//          beforeEach {
//            box = OptionalBox<Int>.none
//          }
//
//          it("should return nil when unwraps") {
//            expect(box.value as Int?) == nil
//          }
//
//          it("should return correct value for isNotSet") {
//            expect(box.isNotSet) == false
//          }
//
//          it("should return correct value for hasValue") {
//            expect(box.hasValue) == true
//          }
//
//          it("should return any box") {
//            expect(box.asAny().isNotSet) == false
//            expect(box.asAny().hasValue) == true
//          }
//
//          context("should compare") {
//            var box2: OptionalBox<Int>!
//            context("when another value is notSet") {
//              beforeEach {
//                box2 = .notSet
//              }
//
//              it("should be not equal") {
//                expect(box) != box2
//              }
//            }
//
//            context("when another value is none") {
//              beforeEach {
//                box2 = OptionalBox<Int>.none
//              }
//
//              it("should be equal") {
//                expect(box) == box2
//              }
//            }
//
//            context("when another value is some") {
//              beforeEach {
//                box2 = OptionalBox<Int>.some(200)
//              }
//
//              it("should be not equal") {
//                expect(box) != box2
//              }
//            }
//          }
//        }
//
//        context("when value is some") {
//          beforeEach {
//            box = OptionalBox<Int>.some(101)
//          }
//
//          it("should return nil when unwraps") {
//            expect(box.value as Int?) == 101
//          }
//
//          it("should return correct value for isNotSet") {
//            expect(box.isNotSet) == false
//          }
//
//          it("should return correct value for hasValue") {
//            expect(box.hasValue) == true
//          }
//
//          it("should return any box") {
//            expect(box.asAny().isNotSet) == false
//            expect(box.asAny().hasValue) == true
//          }
//
//          context("when use wrap helper") {
//            beforeEach {
//              box = (101 as Int?).wrapIntoOptionalBox()
//            }
//
//            it("should return nil when unwraps") {
//              expect(box.value as Int?) == 101
//            }
//          }
//
//          context("should compare") {
//            var box2: OptionalBox<Int>!
//            context("when another value is notSet") {
//              beforeEach {
//                box2 = .notSet
//              }
//
//              it("should be not equal") {
//                expect(box) != box2
//              }
//            }
//
//            context("when another value is none") {
//              beforeEach {
//                box2 = OptionalBox<Int>.none
//              }
//
//              it("should be not equal") {
//                expect(box) != box2
//              }
//            }
//
//            context("when another value is some") {
//              context("when value is same") {
//                beforeEach {
//                  box2 = OptionalBox<Int>.some(101)
//                }
//
//                it("should be equal") {
//                  expect(box) == box2
//                }
//              }
//
//              context("when value is different") {
//                beforeEach {
//                  box2 = OptionalBox<Int>.some(102)
//                }
//
//                it("should be not equal") {
//                  expect(box) != box2
//                }
//              }
//            }
//          }
//        }
//      }
//    }
//  }
