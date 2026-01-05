//
//  UniquelyIdentifiableTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/4/26.
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

import Foundation

import ChouTiTest

import ChouTi

class UniquelyIdentifiableTests: XCTestCase {

  func test_uniqueIdentifier_isUnique() {
    let object1 = TestObject()
    let object2 = TestObject()

    let id1 = object1.uniqueIdentifier
    let id2 = object2.uniqueIdentifier

    expect(id1) != id2
  }

  func test_uniqueIdentifier_isConsistent() {
    let object = TestObject()

    let id1 = object.uniqueIdentifier
    let id2 = object.uniqueIdentifier
    let id3 = object.uniqueIdentifier

    expect(id1) == id2
    expect(id2) == id3
  }

  func test_uniqueIdentifier_persistsAcrossPropertyChanges() {
    let object = TestObject()
    let idBefore = object.uniqueIdentifier

    // modify the object's properties
    object.value = 42

    let idAfter = object.uniqueIdentifier
    expect(idBefore) == idAfter
  }

  func test_uniqueIdentifier_multipleInstances() {
    let count = 100
    var identifiers = Set<String>()

    for _ in 0 ..< count {
      let object = TestObject()
      identifiers.insert(object.uniqueIdentifier)
    }

    // all identifiers should be unique
    expect(identifiers.count) == count
  }

  func test_NSObject_conformsToUniquelyIdentifiable() {
    let object = NSObject()
    let id = object.uniqueIdentifier

    // Should have a valid UUID string
    let uuid = UUID(uuidString: id)
    expect(uuid).toNot(beNil())
  }

  func test_NSObject_uniqueIdentifier_isConsistent() {
    let object = NSObject()

    let id1 = object.uniqueIdentifier
    let id2 = object.uniqueIdentifier

    expect(id1) == id2
  }

  func test_NSObject_differentInstances_haveDifferentIdentifiers() {
    let object1 = NSObject()
    let object2 = NSObject()

    let id1 = object1.uniqueIdentifier
    let id2 = object2.uniqueIdentifier

    expect(id1) != id2
  }

  func test_uniqueIdentifier_worksWithMemoryReuse() throws {
    // this test shows that ObjectIdentifier is not reliable for uniquely identifying objects
    // when the memory address is reused.

    var object: NSObject? = NSObject()
    let objectId1 = try ObjectIdentifier(object.unwrap())
    let uniqueId1 = try object.unwrap().uniqueIdentifier

    // release and re-allocate the object
    object = nil
    object = NSObject()

    // expect the object identifier to be the same, but unique identifier to be different
    let objectId2 = try ObjectIdentifier(object.unwrap())
    let uniqueId2 = try object.unwrap().uniqueIdentifier
    expect(objectId1) == objectId2
    expect(uniqueId1) != uniqueId2
  }

  func test_uniqueIdentifier_withCustomClass() {
    class CustomObject: NSObject {}

    let object1 = CustomObject()
    let object2 = CustomObject()

    let id1 = object1.uniqueIdentifier
    let id2 = object2.uniqueIdentifier

    expect(id1) != id2
    expect(object1.uniqueIdentifier) == id1
    expect(object2.uniqueIdentifier) == id2
  }
}

private class TestObject: NSObject {
  var value: Int = 0
}
