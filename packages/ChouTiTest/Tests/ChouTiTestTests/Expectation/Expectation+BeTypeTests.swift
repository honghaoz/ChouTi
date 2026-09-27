//
//  Expectation+BeTypeTests.swift
//  ChouTi
//
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

class BeTypeExpectationTests: XCTestCase {

  func test_concreteMetatypes() {
    typealias Integer = Int

    expect(Int.self) == Int.self
    expect(Int.self) == Integer.self
    expect(Int.self) != String.self
    expect(TypeComparisonValue.self) == TypeComparisonValue.self
    expect(TypeComparisonValue.self) != TypeComparisonOtherValue.self
    expect(TypeComparisonEnum.self) == TypeComparisonEnum.self
    expect(TypeComparisonEnum.self) != TypeComparisonValue.self
    expect([Int].self) == [Int].self
    expect([Int].self) != [String].self
    expect(Int?.self) == Int?.self
    expect(Int?.self) != Int.self
    expect((Int, String).self) == (Int, String).self
    expect((() -> Void).self) == (() -> Void).self
  }

  func test_exactClassIdentity() {
    let subclass: TypeComparisonBase.Type = TypeComparisonSubclass.self

    expect(TypeComparisonBase.self) == TypeComparisonBase.self
    expect(TypeComparisonSubclass.self) != TypeComparisonBase.self
    expect(TypeComparisonBase.self) != TypeComparisonSubclass.self
    expect(subclass) == TypeComparisonSubclass.self
    expect(subclass) != TypeComparisonBase.self
  }

  func test_erasedMetatypes() {
    let valueType: Any.Type = TypeComparisonValue.self
    let classType: AnyClass = TypeComparisonSubclass.self
    let expectedType: Any.Type = TypeComparisonSubclass.self

    expect(valueType) == TypeComparisonValue.self
    expect(valueType) != classType
    expect(classType) == expectedType
    expect(classType) != TypeComparisonBase.self
  }

  func test_protocolMetatypes() {
    let conformingType: any TypeComparisonProtocol.Type = TypeComparisonValue.self

    expect(conformingType) == TypeComparisonValue.self
    expect(conformingType) != TypeComparisonOtherValue.self
    expect(TypeComparisonProtocol.self) == TypeComparisonProtocol.self
    expect(TypeComparisonProtocol.self) != TypeComparisonValue.self
    expect(Any.self) == Any.self
    expect(Any.self) != AnyObject.self
  }

  func test_optionalMetatypes() {
    let valueType: Any.Type? = Int.self
    let otherType: Any.Type? = String.self
    let missingType: Any.Type? = nil

    expect(valueType) == Int.self
    expect(valueType) == valueType
    expect(valueType) != String.self
    expect(valueType) != otherType
    expect(valueType) != nil
    expect(valueType) != missingType
    expect(missingType) == nil
    expect(missingType) == missingType
    expect(missingType) != Int.self
    expect(missingType) != valueType
    expect(valueType).to(beType(Int.self))
    expect(valueType).toNot(beType(String.self))
    expect(missingType).to(beNil())
    expect(missingType).toNot(beType(Int.self))
  }

  func test_optionalConcreteMetatypes() {
    let valueType: Int.Type? = Int.self
    let missingType: Int.Type? = nil

    expect(valueType) == Int.self
    expect(valueType) != String.self
    expect(valueType) != nil
    expect(missingType) == nil
    expect(missingType) != Int.self
  }

  func test_optionalClassMetatypes() {
    let classType: AnyClass? = TypeComparisonSubclass.self
    let missingClass: AnyClass? = nil
    let concreteClass: TypeComparisonBase.Type? = TypeComparisonSubclass.self

    expect(classType) == TypeComparisonSubclass.self
    expect(classType) != TypeComparisonBase.self
    expect(classType) == concreteClass
    expect(classType) != nil
    expect(missingClass) == nil
    expect(missingClass) != classType
    expect(concreteClass) == TypeComparisonSubclass.self
    expect(concreteClass) != TypeComparisonBase.self
    expect(concreteClass) != nil
  }

  func test_objectGetClass() {
    let object = NSObject()

    expect(object_getClass(object)) == NSObject.self
    expect(object_getClass(object)) != NSString.self
    expect(object_getClass(object)) != nil
    expect(object_getClass(nil)) == nil
  }

  func test_beType() {
    expect(Int.self).to(beType(Int.self))
    expect(Int.self).toNot(beType(String.self))
    expect(TypeComparisonSubclass.self).toNot(beType(TypeComparisonBase.self))
    expect(beType(Int.self).description) == "be type \"Int\""
  }

  func test_eventualMatcher() {
    expect(Int.self).toEventually(beType(Int.self))
    expect(Int.self).toEventuallyNot(beType(String.self))
    expect(Int.self as Any.Type?).toEventually(beType(Int.self))
    expect(nil as Any.Type?).toEventuallyNot(beType(Int.self))
  }

  func test_evaluatesOnceAndKeepsDescriptionLazy() {
    var evaluations = 0
    var descriptions = 0
    func value() -> Any.Type {
      evaluations += 1
      return Int.self
    }
    func description() -> String {
      descriptions += 1
      return "metatype"
    }

    let expression = expect(value(), description())
    expression == Int.self
    expression != String.self
    expect(evaluations) == 1
    expect(descriptions) == 0
  }

  func test_optionalEvaluatesOnceAndKeepsDescriptionLazy() {
    var evaluations = 0
    var descriptions = 0
    func value() -> Any.Type? {
      evaluations += 1
      return Int.self
    }
    func description() -> String {
      descriptions += 1
      return "optional metatype"
    }

    let expression = expect(value(), description())
    expression == Int.self
    expression != nil
    expect(evaluations) == 1
    expect(descriptions) == 0
  }

  func test_throwingExpressionsStillSupportErrorMatchers() {
    expect(try throwingTypeComparison()).to(throwAnError())
    expect(try throwingOptionalTypeComparison()).to(throwAnError())
  }
}

class BeTypeExpectationFailureTests: FailureCapturingTestCase {

  func test_equalityFailure() {
    expect(Int.self) == String.self
    assertFailure(expectedMessage: #"failed - expect "Int" to be type "String""#)
  }

  func test_inequalityFailure() {
    expect(Int.self) != Int.self
    assertFailure(expectedMessage: #"failed - expect "Int" to not be type "Int""#)
  }

  func test_failureWithDescription() {
    expect(Int.self, "value type") == String.self
    assertFailure(expectedMessage: #"failed - expect "value type" ("Int") to be type "String""#)
  }

  func test_matcherFailure() {
    expect(Int.self).to(beType(String.self))
    assertFailure(expectedMessage: #"failed - expect "Int" to be type "String""#)
  }

  func test_optionalEqualityFailure() {
    expect(Int.self as Any.Type?) == String.self
    assertFailure(expectedMessage: #"failed - expect "Int" to be type "String""#)
  }

  func test_optionalInequalityFailureWithDescription() {
    expect(Int.self as Any.Type?, "value type") != Int.self
    assertFailure(expectedMessage: #"failed - expect "value type" ("Int") to not be type "Int""#)
  }

  func test_missingTypeFailure() {
    expect(nil as Any.Type?) == Int.self
    assertFailure(expectedMessage: #"failed - expect "nil" to be type "Int""#)
  }

  func test_expectedNilFailure() {
    expect(Int.self as Any.Type?) == nil
    assertFailure(expectedMessage: #"failed - expect "Int" to be nil"#)
  }

  func test_nilInequalityFailure() {
    expect(nil as Any.Type?) != nil
    assertFailure(expectedMessage: #"failed - expect "nil" to not be nil"#)
  }

  func test_throwingExpressionFailure() {
    expect(try throwingTypeComparison()) == Int.self
    assertFailure(expectedMessage: #"failed - expect not to throw error: "missingType""#)
  }

  func test_throwingOptionalExpressionFailure() {
    expect(try throwingOptionalTypeComparison()) != nil
    assertFailure(expectedMessage: #"failed - expect not to throw error: "missingType""#)
  }
}

private protocol TypeComparisonProtocol {}
private struct TypeComparisonValue: TypeComparisonProtocol {}
private struct TypeComparisonOtherValue: TypeComparisonProtocol {}
private enum TypeComparisonEnum {}
private class TypeComparisonBase {}
private class TypeComparisonSubclass: TypeComparisonBase {}

private enum TypeComparisonError: Error {
  case missingType
}

private func throwingTypeComparison() throws -> Any.Type {
  throw TypeComparisonError.missingType
}

private func throwingOptionalTypeComparison() throws -> Any.Type? {
  throw TypeComparisonError.missingType
}
