//
//  Expectation+BeTypeTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/26/26.
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

import ChouTiTest
import XCTest

import Foundation

class Expectation_BeTypeTests: XCTestCase {

  func test_beType() {
    expect(Int.self).to(beType(Int.self))
    expect(Int.self).toNot(beType(String.self))
    expect(beType(Int.self).description) == #"be type "Swift.Int""#
  }

  func test_equal_concreteTypes() {
    typealias Integer = Int

    expect(Int.self) == Int.self
    expect(Int.self) == Integer.self
    expect(Int.self) != String.self
    expect(Int?.self) == Int?.self
    expect(Int?.self) != Int.self
    expect([Int].self) == [Int].self
    expect([Int].self) != [String].self
    expect((Int, String).self) == (Int, String).self
    expect((() -> Void).self) == (() -> Void).self
    expect(Value.self) == Value.self
    expect(Value.self) != OtherValue.self
    expect(FeatureA.State.self) != FeatureB.State.self
  }

  func test_equal_classTypes() {
    let subclass: Base.Type = Subclass.self
    let instance: Base = Subclass()

    expect(Base.self) == Base.self
    expect(Subclass.self) != Base.self
    expect(subclass) == Subclass.self
    expect(subclass) != Base.self
    expect(type(of: instance)) == Subclass.self
  }

  func test_equal_existentialTypes() {
    let anyType: Any.Type = Value.self
    let anyClass: AnyClass = Subclass.self
    let protocolType: any ValueProtocol.Type = Value.self

    expect(anyType) == Value.self
    expect(anyType) != OtherValue.self
    expect(anyType) != anyClass
    expect(anyClass) == Subclass.self
    expect(anyClass) != Base.self
    expect(protocolType) == Value.self
    expect(protocolType) != OtherValue.self
    expect(ValueProtocol.self) == ValueProtocol.self
    expect(ValueProtocol.self) != Value.self
    expect(Any.self) == Any.self
    expect(Any.self) != AnyObject.self
  }

  func test_equal_optionalTypes() {
    let optionalType: Any.Type? = Int.self
    let optionalConcreteType: Int.Type? = Int.self
    let nilType: Any.Type? = nil

    expect(optionalType) == Int.self
    expect(optionalType) != String.self
    expect(optionalType) != nil
    expect(optionalConcreteType) == Int.self
    expect(optionalConcreteType) != String.self
    expect(optionalConcreteType) != nil
    expect(nilType) == nil
    expect(nilType) != Int.self
  }

  func test_equal_objectGetClass() {
    let object = NSObject()

    expect(object_getClass(object)) == NSObject.self
    expect(object_getClass(object)) != NSString.self
    expect(object_getClass(object)) != nil
    expect(object_getClass(nil)) == nil
  }

  func test_toEventually() {
    expect(Int.self).toEventually(beType(Int.self))
    expect(Int.self).toEventuallyNot(beType(String.self))
    expect(object_getClass(NSObject())).toEventually(beType(NSObject.self))
    expect(object_getClass(nil)).toEventuallyNot(beType(NSObject.self))
  }
}

class Expectation_BeTypeFailureMessageTests: FailureCapturingTestCase {

  func test_beType() {
    expect(Int.self).to(beType(String.self))
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to be type "Swift.String""#)

    expect(Int.self).toNot(beType(Int.self))
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to not be type "Swift.Int""#)
  }

  func test_equal() {
    expect(Int.self) == String.self
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to be type "Swift.String""#)

    expect(Int.self, "type") == String.self
    assertFailure(expectedMessage: #"failed - expect "type" ("Swift.Int") to be type "Swift.String""#)

    expect(Int.self) != Int.self
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to not be type "Swift.Int""#)

    expect(Int.self, "type") != Int.self
    assertFailure(expectedMessage: #"failed - expect "type" ("Swift.Int") to not be type "Swift.Int""#)
  }

  func test_equal_qualifiedTypeNames() {
    expect(FeatureA.State.self) == FeatureB.State.self
    assertFailure(expectedMessage: #"failed - expect "ChouTiTestTests.FeatureA.State" to be type "ChouTiTestTests.FeatureB.State""#)

    expect(Base.self) == Subclass.self
    assertFailure(expectedMessage: #"failed - expect "ChouTiTestTests.Base" to be type "ChouTiTestTests.Subclass""#)
  }

  func test_equal_optionalType() {
    expect(Int.self as Any.Type?) == String.self
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to be type "Swift.String""#)

    expect(Int.self as Any.Type?, "type") == String.self
    assertFailure(expectedMessage: #"failed - expect "type" ("Swift.Int") to be type "Swift.String""#)

    expect(Int.self as Any.Type?) != Int.self
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to not be type "Swift.Int""#)

    expect(Int.self as Any.Type?, "type") != Int.self
    assertFailure(expectedMessage: #"failed - expect "type" ("Swift.Int") to not be type "Swift.Int""#)

    expect(nil as Any.Type?) == Int.self
    assertFailure(expectedMessage: #"failed - expect "nil" to be type "Swift.Int""#)

    expect(Int.self as Any.Type?) == nil
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to be nil"#)

    expect(nil as Any.Type?) != nil
    assertFailure(expectedMessage: #"failed - expect "nil" to not be nil"#)
  }

  func test_equal_objectGetClass() {
    expect(object_getClass(NSObject())) == NSString.self
    assertFailure(expectedMessage: #"failed - expect "NSObject" to be type "NSString""#)

    expect(object_getClass(nil)) == NSObject.self
    assertFailure(expectedMessage: #"failed - expect "nil" to be type "NSObject""#)
  }

  func test_equal_throwingExpression() {
    expect(try makeType()) == Int.self
    assertFailure(expectedMessage: #"failed - expect not to throw error: "type""#)

    expect(try makeOptionalType()) == Int.self
    assertFailure(expectedMessage: #"failed - expect not to throw error: "optionalType""#)
  }

  func test_toEventually() {
    expect(Int.self).toEventually(beType(String.self), timeout: 0.05)
    assertFailure(expectedMessage: #"failed - expect "Swift.Int" to be type "Swift.String" eventually"#)

    expect(object_getClass(NSObject())).toEventually(beType(NSString.self), timeout: 0.05)
    assertFailure(expectedMessage: #"failed - expect "NSObject" to be type "NSString" eventually"#)
  }
}

// MARK: - Fixtures

private protocol ValueProtocol {}
private struct Value: ValueProtocol {}
private struct OtherValue: ValueProtocol {}

private class Base {}
private final class Subclass: Base {}

private enum FeatureA {
  struct State {}
}

private enum FeatureB {
  struct State {}
}

private enum TypeError: Error {
  case type
  case optionalType
}

private func makeType() throws -> Any.Type {
  throw TypeError.type
}

private func makeOptionalType() throws -> Any.Type? {
  throw TypeError.optionalType
}
