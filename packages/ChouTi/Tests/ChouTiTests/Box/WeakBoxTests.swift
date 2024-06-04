//
//  WeakBoxTests.swift
//
//  Created by Honghao Zhang on 11/4/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

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
    expect(box.object) == nil
  }

  func testCanGetBackObject() {
    let object = NSObject()
    let box = WeakBox(object)
    expect(box.object) === object
  }

  func testWithStruct() {
    let someStruct = StructFoo()
    let box = WeakBox(someStruct)
    expect(box.object) == nil
  }

  func testWithNSObjectNil() {
    let box = WeakBox<NSObject>(nil)
    expect(box.object) == nil
  }

  func testWithAnyObjectWeakValue() {
    let box = WeakBox<AnyObject>(ClassFoo())
    expect(box.object) == nil
  }

  func testWithAnyObjectStrongValue() {
    let foo = ClassFoo()
    let box = WeakBox<AnyObject>(foo)
    expect(box.object) === foo
  }

  func testWithAnyObjectNil() {
    let box = WeakBox<AnyObject>(nil)
    expect(box.object) == nil
  }

  func testStructSetObject() {
    let someStruct = StructFoo()
    let box = WeakBox(someStruct)
    let someStruct2 = StructFoo()
    box.object = someStruct2
    expect(box.object) == nil
  }

  func testAnyObjectSetObject() {
    let foo = ClassFoo()
    let box = WeakBox<AnyObject>(foo)
    expect(box.object) === foo
    let foo2 = ClassFoo()
    box.object = foo2
    expect(box.object) === foo2
  }

  func test_Equatable() {
    do {
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(nil)
      expect(box1) == box2
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(nil)
      expect(box1) != box2
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(object)
      expect(box1) != box2
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(object)
      expect(box1) == box2
    }
  }

  func test_Hashable() {
    do {
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(nil)
      expect(box1.hashValue) == box2.hashValue
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(nil)
      expect(box1.hashValue) != box2.hashValue
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(nil)
      let box2 = WeakBox<NSObject>(object)
      expect(box1.hashValue) != box2.hashValue
    }

    do {
      let object = NSObject()
      let box1 = WeakBox<NSObject>(object)
      let box2 = WeakBox<NSObject>(object)
      expect(box1.hashValue) == box2.hashValue
    }
  }
}
