//
//  WeakBoxTests.swift
//
//  Created by Honghao Zhang on 11/4/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

class WeakBoxTests: XCTestCase {

  struct StructFoo {
    let bar = 0
    init() {}
  }

  class ClassFoo {
    let bar = 1
  }

  func testWeakReference() {
    let box = WeakBox(NSObject())
    XCTAssertNil(box.object)
  }

  func testCanGetBackObject() {
    let object = NSObject()
    let box = WeakBox(object)
    XCTAssertTrue(box.object === object)
  }

  func testWithStruct() {
    let someStruct = StructFoo()
    let box = WeakBox(someStruct)
    XCTAssertNil(box.object)
  }

  func testWithNSObjectNil() {
    let box = WeakBox<NSObject>(nil)
    XCTAssertNil(box.object)
  }

  func testWithAnyObjectWeakValue() {
    let box = WeakBox<AnyObject>(ClassFoo())
    XCTAssertNil(box.object)
  }

  func testWithAnyObjectStrongValue() {
    let foo = ClassFoo()
    let box = WeakBox<AnyObject>(foo)
    XCTAssert(box.object === foo)
  }

  func testWithAnyObjectNil() {
    let box = WeakBox<AnyObject>(nil)
    XCTAssertNil(box.object)
  }

  func testStructSetObject() {
    let someStruct = StructFoo()
    let box = WeakBox(someStruct)
    let someStruct2 = StructFoo()
    box.object = someStruct2
    XCTAssertNil(box.object)
  }

  func testAnyObjectSetObject() {
    let foo = ClassFoo()
    let box = WeakBox<AnyObject>(foo)
    XCTAssert(box.object === foo)
    let foo2 = ClassFoo()
    box.object = foo2
    XCTAssert(box.object === foo2)
  }

  func test_Equatable() {
    do {
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(nil)
      XCTAssertEqual(box1, box2)
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(nil)
      XCTAssertNotEqual(box1, box2)
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(object)
      XCTAssertNotEqual(box1, box2)
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(object)
      XCTAssertEqual(box1, box2)
    }
  }

  func test_Hashable() {
    do {
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(nil)
      XCTAssertEqual(box1.hashValue, box2.hashValue)
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(nil)
      XCTAssertNotEqual(box1.hashValue, box2.hashValue)
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(object)
      XCTAssertNotEqual(box1.hashValue, box2.hashValue)
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(object)
      XCTAssertEqual(box1.hashValue, box2.hashValue)
    }
  }
}
