//
//  HashableBoxTests.swift
//
//  Created by Honghao Zhang on 2/27/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest

import ChouTi

class HashableBoxTests: XCTestCase {

  func testHashableBox_Int() {
    let box = HashableBox(key: 1, "abc")
    let box2 = HashableBox(key: 1, "def")
    XCTAssertEqual(box, box2, "boxes with the same key should be equal")

    XCTAssertEqual(box.hashValue, box.hashValue)

    XCTAssertEqual(box.key, 1)
    XCTAssertEqual(box.value, "abc")
  }

  func testHashableBox_String() {
    let box = HashableBox(key: "key2", "abc")
    let box2 = HashableBox(key: "key2", "def")
    XCTAssertEqual(box, box2, "boxes with the same key should be equal")

    XCTAssertEqual(box.key, "key2")
    XCTAssertEqual(box.value, "abc")
  }
}

//  import Nimble
//  import Quick
//
//  class HashableBoxTests: QuickSpec {
//
//    override func spec() {
//      describe("for a HashableBox") {
//        context("when box key is Int") {
//          var box: HashableBox<Int, String>!
//          beforeEach {
//            box = HashableBox<Int, String>(key: 1, "abc")
//          }
//
//          it("should use key to compare") {
//            let box2 = HashableBox<Int, String>(key: 1, "def")
//            expect(box) == box2
//          }
//
//          it("should generate correct hash value") {
//            expect(box.hashValue) == box.hashValue
//          }
//
//          it("should get correct value") {
//            expect(box.key) == 1
//            expect(box.value) == "abc"
//          }
//        }
//
//        context("when box key is String") {
//          var box: HashableBox<String, String>!
//          beforeEach {
//            box = .key("key2", "abc")
//          }
//
//          it("should use key to compare") {
//            let box2 = HashableBox<String, String>(key: "key2", "def")
//            expect(box) == box2
//          }
//
//          it("should get correct value") {
//            expect(box.key) == "key2"
//            expect(box.value) == "abc"
//          }
//        }
//      }
//    }
//  }
