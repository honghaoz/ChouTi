//
//  Any+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/4/24.
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
