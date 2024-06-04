//
//  Any+ExtensionsTests.swift
//
//  Created by Honghao Zhang on 1/4/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class Any_ExtensionsTests: XCTestCase {

  func testHashWithNil() throws {
    var hasher = Hasher()
    try ChouTi.hash(nil, into: &hasher)
    let hashValue = hasher.finalize()

    var hasher2 = Hasher()
    try ChouTi.hash(nil, into: &hasher2)
    let hashValue2 = hasher2.finalize()
    expect(hashValue) == hashValue2
  }

  func testHashWithHashableType() throws {
    var hasher = Hasher()
    let number: Any = 123
    try ChouTi.hash(number, into: &hasher)

    var expectedHasher = Hasher()
    expectedHasher.combine(123 as Int)
    expect(hasher.finalize()) == expectedHasher.finalize()
  }

  func testHashWithReferenceType() throws {
    class MyClass {}
    let object: Any = MyClass()
    var hasher = Hasher()
    try ChouTi.hash(object, into: &hasher)

    var expectedHasher = Hasher()
    expectedHasher.combine(ObjectIdentifier(object as AnyObject))
    expect(hasher.finalize()) == expectedHasher.finalize()
  }

  func testHashWithNonReferenceType() throws {
    struct MyStruct {
      let value: Int
    }
    let object: Any = MyStruct(value: 1)
    var hasher = Hasher()
    expect(try ChouTi.hash(object, into: &hasher)).to(throwErrorOfType(HashAnyError.self))
    expect(try ChouTi.hash(object, into: &hasher)).to(throwErrorOfType(Swift.Error.self))
    expect(try ChouTi.hash(object, into: &hasher)).to(throwAnError())

    do {
      try ChouTi.hash(object, into: &hasher)
    } catch {
      if case HashAnyError.unhashable(let value) = error {
        expect(try? (value as? MyStruct).unwrap().value) == 1
      } else {
        fail("unexpected error")
      }
    }
  }

  func testHashWithHashableStruct() throws {
    struct MyStruct: Hashable {
      let value: Int
    }
    let object: Any = MyStruct(value: 123)
    var hasher = Hasher()
    try ChouTi.hash(object, into: &hasher)

    var expectedHasher = Hasher()
    expectedHasher.combine(MyStruct(value: 123))
    expect(hasher.finalize()) == expectedHasher.finalize()
  }

  func testHashWithHashableStructArray() throws {
    struct MyStruct: Hashable {
      let value: Int
    }
    let object: Any = [MyStruct(value: 123), MyStruct(value: 456)]
    var hasher = Hasher()
    try ChouTi.hash(object, into: &hasher)

    var expectedHasher = Hasher()
    expectedHasher.combine([MyStruct(value: 123), MyStruct(value: 456)])
    expect(hasher.finalize()) == expectedHasher.finalize()
  }

  func test_hashValue_nil() throws {
    try expect(ChouTi.hashValue(nil)) == ChouTi.hashValue(nil)
  }

  func test_hashValue_hashableType() throws {
    try expect(ChouTi.hashValue(123)) == ChouTi.hashValue(123)
  }

  func test_hashValue_referenceType() throws {
    class MyClass {}
    let object: Any = MyClass()
    try expect(ChouTi.hashValue(object)) == ChouTi.hashValue(object)
  }

  func test_hashValue_nonReferenceType() throws {
    struct MyStruct {
      let value: Int
    }
    let object: Any = MyStruct(value: 1)
    expect(try ChouTi.hashValue(object)).to(throwAnError())
  }

  func test_hashValue_hashableStruct() throws {
    struct MyStruct: Hashable {
      let value: Int
    }
    let object: Any = MyStruct(value: 123)
    try expect(ChouTi.hashValue(object)) == ChouTi.hashValue(MyStruct(value: 123))
  }

  func test_hashValue_hashableStructArray() throws {
    struct MyStruct: Hashable {
      let value: Int
    }
    let object: Any = [MyStruct(value: 123), MyStruct(value: 456)]
    try expect(ChouTi.hashValue(object)) == ChouTi.hashValue([MyStruct(value: 123), MyStruct(value: 456)])
  }
}
