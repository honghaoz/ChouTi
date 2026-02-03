//
//  InstanceMethodInterceptor+SingleArgVoidTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2/3/26.
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

//
//  NOTE: This test file focuses on coverage for generated single-arg void
//  interceptors (CGSize/CGRect/AnyObject) and the dispatch paths.
//

import Foundation
import ObjectiveC
import XCTest

import ChouTiTest

@testable import ChouTi

class InstanceMethodInterceptor_SingleArgVoidTests: XCTestCase {

  final class TypeTestObject: NSObject {

    @objc dynamic var value: Int = 0

    private(set) var boolCallCount = 0
    private(set) var sizeCallCount = 0
    private(set) var rectCallCount = 0
    private(set) var objectCallCount = 0
    private(set) var optionalObjectCallCount = 0
    private(set) var optionalNumberCallCount = 0

    @objc dynamic func withBool(_ bool: Bool) {
      boolCallCount += 1
    }

    @objc dynamic func withSize(_ size: CGSize) {
      sizeCallCount += 1
    }

    @objc dynamic func withRect(_ rect: CGRect) {
      rectCallCount += 1
    }

    @objc dynamic func withObject(_ object: NSObject) {
      objectCallCount += 1
    }

    @objc dynamic func withOptionalObject(_ object: NSObject?) {
      optionalObjectCallCount += 1
    }

    @objc dynamic func withOptionalNumber(_ number: NSNumber?) {
      optionalNumberCallCount += 1
    }
  }

  private struct MismatchCase {
    let selector: Selector
    let intercept: (TypeTestObject) -> CancellableToken
    let invoke: (TypeTestObject) -> Void
    let wrongValue: Any
  }

  private func installMismatchedHook(on object: TypeTestObject, selector: Selector, wrongValue: Any) {
    let state = InstanceMethodInterceptor.state(for: object)
    var hooks = InstanceMethodInterceptor.HookBlocksWithArg()
    let token = ValueCancellableToken(
      value: { _, _, _, callOriginal in
        callOriginal(wrongValue)
      } as InstanceMethodInterceptor.InstanceMethodInvokeBlockWithArgAny
    ) { _ in }
    token.store(in: &hooks)
    state.hookBlocksBySelectorWithArg[selector] = hooks
  }

  // MARK: - Non-KVO

  func test_singleArg_types_areIntercepted_nonKVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    var boolHooks = 0
    var sizeHooks = 0
    var rectHooks = 0
    var objectHooks = 0

    let boolToken = object.intercept(selector: #selector(TypeTestObject.withBool(_:))) { (_, _, value: Bool, callOriginal) in
      boolHooks += 1
      callOriginal(value)
    }
    let sizeToken = object.intercept(selector: #selector(TypeTestObject.withSize(_:))) { (_, _, value: CGSize, callOriginal) in
      sizeHooks += 1
      callOriginal(value)
    }
    let rectToken = object.intercept(selector: #selector(TypeTestObject.withRect(_:))) { (_, _, value: CGRect, callOriginal) in
      rectHooks += 1
      callOriginal(value)
    }
    let objectToken = object.intercept(selector: #selector(TypeTestObject.withObject(_:))) { (_, _, value: NSObject, callOriginal) in
      objectHooks += 1
      callOriginal(value)
    }

    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    object.withBool(true)
    object.withSize(CGSize(width: 1, height: 2))
    object.withRect(CGRect(x: 1, y: 2, width: 3, height: 4))
    object.withObject(NSObject())

    expect(boolHooks) == 1
    expect(sizeHooks) == 1
    expect(rectHooks) == 1
    expect(objectHooks) == 1
    expect(object.boolCallCount) == 1
    expect(object.sizeCallCount) == 1
    expect(object.rectCallCount) == 1
    expect(object.objectCallCount) == 1

    boolToken.cancel()
    sizeToken.cancel()
    rectToken.cancel()
    objectToken.cancel()
    expect(getClassName(object)) == originalClassName
  }

  func test_singleArg_optionalObject_isIntercepted_nonKVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    var optionalObjectHooks = 0
    var receivedValues: [NSObject?] = []
    let objectValue = NSObject()

    let token = object.intercept(selector: #selector(TypeTestObject.withOptionalObject(_:))) { (_, _, value: NSObject?, callOriginal) in
      optionalObjectHooks += 1
      receivedValues.append(value)
      callOriginal(value)
    }

    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    object.withOptionalObject(nil)
    object.withOptionalObject(objectValue)

    expect(optionalObjectHooks) == 2
    expect(object.optionalObjectCallCount) == 2
    expect(receivedValues.count) == 2
    expect(receivedValues[0]) == nil
    if let secondValue = receivedValues[1] {
      expect(secondValue === objectValue) == true
    } else {
      fail("Expected non-nil value for optional object")
    }

    token.cancel()
    expect(getClassName(object)) == originalClassName
  }

  func test_singleArg_optionalNumber_isIntercepted_nonKVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    var optionalNumberHooks = 0
    var receivedValues: [NSNumber?] = []
    let numberValue = NSNumber(value: true)

    let token = object.intercept(selector: #selector(TypeTestObject.withOptionalNumber(_:))) { (_, _, value: NSNumber?, callOriginal) in
      optionalNumberHooks += 1
      receivedValues.append(value)
      callOriginal(value)
    }

    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    object.withOptionalNumber(nil)
    object.withOptionalNumber(numberValue)

    expect(optionalNumberHooks) == 2
    expect(object.optionalNumberCallCount) == 2
    expect(receivedValues.count) == 2
    expect(receivedValues[0]) == nil
    if let secondValue = receivedValues[1] {
      expect(secondValue === numberValue) == true
    } else {
      fail("Expected non-nil value for optional number")
    }

    token.cancel()
    expect(getClassName(object)) == originalClassName
  }

  func test_singleArg_unsupportedType_isIgnored() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    var hookCount = 0
    var assertionMessage: String?
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      assertionMessage = message
    }
    defer {
      Assert.resetTestAssertionFailureHandler()
    }

    object.intercept(selector: #selector(TypeTestObject.withSize(_:))) { (_, _, value: UInt8, callOriginal) in
      hookCount += 1
      callOriginal(value)
    }

    expect(assertionMessage) == "intercept only supports void methods with one arg of supported types"
    expect(getClassName(object)) == originalClassName

    object.withSize(CGSize(width: 1, height: 2))
    expect(hookCount) == 0
    expect(object.sizeCallCount) == 1
  }

  func test_singleArg_typeMismatch_triggersAssertion_nonKVO() {
    let cases: [MismatchCase] = [
      MismatchCase(
        selector: #selector(TypeTestObject.withBool(_:)),
        intercept: { object in
          object.intercept(selector: #selector(TypeTestObject.withBool(_:))) { (_, _, value: Bool, callOriginal) in
            callOriginal(value)
          }
        },
        invoke: { object in
          object.withBool(true)
        },
        wrongValue: 1
      ),
      MismatchCase(
        selector: #selector(TypeTestObject.withSize(_:)),
        intercept: { object in
          object.intercept(selector: #selector(TypeTestObject.withSize(_:))) { (_, _, value: CGSize, callOriginal) in
            callOriginal(value)
          }
        },
        invoke: { object in
          object.withSize(CGSize(width: 1, height: 2))
        },
        wrongValue: 1
      ),
      MismatchCase(
        selector: #selector(TypeTestObject.withRect(_:)),
        intercept: { object in
          object.intercept(selector: #selector(TypeTestObject.withRect(_:))) { (_, _, value: CGRect, callOriginal) in
            callOriginal(value)
          }
        },
        invoke: { object in
          object.withRect(CGRect(x: 1, y: 2, width: 3, height: 4))
        },
        wrongValue: 1
      ),
    ]

    for testCase in cases {
      let object = TypeTestObject()
      var assertionMessage: String?
      Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
        assertionMessage = message
      }

      let token = testCase.intercept(object)
      installMismatchedHook(on: object, selector: testCase.selector, wrongValue: testCase.wrongValue)
      testCase.invoke(object)

      expect(assertionMessage) == "intercept arg type mismatch"
      token.cancel()
      Assert.resetTestAssertionFailureHandler()
    }
  }

  func test_singleArg_typeMismatch_triggersAssertion_KVO() {
    let cases: [MismatchCase] = [
      MismatchCase(
        selector: #selector(TypeTestObject.withBool(_:)),
        intercept: { object in
          object.intercept(selector: #selector(TypeTestObject.withBool(_:))) { (_, _, value: Bool, callOriginal) in
            callOriginal(value)
          }
        },
        invoke: { object in
          object.withBool(true)
        },
        wrongValue: 1
      ),
      MismatchCase(
        selector: #selector(TypeTestObject.withSize(_:)),
        intercept: { object in
          object.intercept(selector: #selector(TypeTestObject.withSize(_:))) { (_, _, value: CGSize, callOriginal) in
            callOriginal(value)
          }
        },
        invoke: { object in
          object.withSize(CGSize(width: 1, height: 2))
        },
        wrongValue: 1
      ),
      MismatchCase(
        selector: #selector(TypeTestObject.withRect(_:)),
        intercept: { object in
          object.intercept(selector: #selector(TypeTestObject.withRect(_:))) { (_, _, value: CGRect, callOriginal) in
            callOriginal(value)
          }
        },
        invoke: { object in
          object.withRect(CGRect(x: 1, y: 2, width: 3, height: 4))
        },
        wrongValue: 1
      ),
    ]

    for testCase in cases {
      let object = TypeTestObject()
      var assertionMessage: String?
      Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
        assertionMessage = message
      }

      let observation = object.observe(\.value, options: [.new]) { _, _ in }
      _ = observation

      let token = testCase.intercept(object)
      installMismatchedHook(on: object, selector: testCase.selector, wrongValue: testCase.wrongValue)
      testCase.invoke(object)

      expect(assertionMessage) == "intercept arg type mismatch"

      token.cancel()
      observation.invalidate()
      Assert.resetTestAssertionFailureHandler()
    }
  }

  func test_singleArg_optionalObject_utilityPaths_areCovered() {
    let object = TypeTestObject()
    let selector = #selector(TypeTestObject.withOptionalObject(_:))

    var receivedValues: [NSObject?] = []
    var originalValues: [Any?] = []
    let objectValue = NSObject()

    let token = object.intercept(selector: selector) { (_, _, value: NSObject?, callOriginal) in
      receivedValues.append(value)
      callOriginal(value)
    }

    InstanceMethodInterceptor.invokeHooksWithAnyArg(on: object, selector: selector, arg: nil) { value in
      originalValues.append(value)
    }

    InstanceMethodInterceptor.invokeHooksWithAnyArg(on: object, selector: selector, arg: objectValue) { value in
      originalValues.append(value)
    }

    expect(receivedValues.count) == 2
    expect(receivedValues[0]) == nil
    if let secondValue = receivedValues[1] {
      expect(secondValue === objectValue) == true
    } else {
      fail("Expected non-nil value for optional object")
    }

    expect(originalValues.count) == 2
    expect(originalValues[0]) == nil
    if let secondValue = originalValues[1] as? NSObject {
      expect(secondValue === objectValue) == true
    } else {
      fail("Expected non-nil value for original object")
    }

    token.cancel()
  }

  // MARK: - KVO

  func test_singleArg_types_areIntercepted_KVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    var boolHooks = 0
    var sizeHooks = 0
    var rectHooks = 0
    var objectHooks = 0

    let boolToken = object.intercept(selector: #selector(TypeTestObject.withBool(_:))) { (_, _, value: Bool, callOriginal) in
      boolHooks += 1
      callOriginal(value)
    }

    let sizeToken = object.intercept(selector: #selector(TypeTestObject.withSize(_:))) { (_, _, value: CGSize, callOriginal) in
      sizeHooks += 1
      callOriginal(value)
    }
    let rectToken = object.intercept(selector: #selector(TypeTestObject.withRect(_:))) { (_, _, value: CGRect, callOriginal) in
      rectHooks += 1
      callOriginal(value)
    }
    let objectToken = object.intercept(selector: #selector(TypeTestObject.withObject(_:))) { (_, _, value: NSObject, callOriginal) in
      objectHooks += 1
      callOriginal(value)
    }

    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    object.withBool(true)
    object.withSize(CGSize(width: 1, height: 2))
    object.withRect(CGRect(x: 1, y: 2, width: 3, height: 4))
    object.withObject(NSObject())

    expect(boolHooks) == 1
    expect(sizeHooks) == 1
    expect(rectHooks) == 1
    expect(objectHooks) == 1
    expect(object.boolCallCount) == 1
    expect(object.sizeCallCount) == 1
    expect(object.rectCallCount) == 1
    expect(object.objectCallCount) == 1

    boolToken.cancel()
    sizeToken.cancel()
    rectToken.cancel()
    objectToken.cancel()

    observation.invalidate()
    expect(getClassName(object)) == originalClassName
  }

  func test_singleArg_optionalObject_isIntercepted_KVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    var optionalObjectHooks = 0
    var receivedValues: [NSObject?] = []
    let objectValue = NSObject()

    let token = object.intercept(selector: #selector(TypeTestObject.withOptionalObject(_:))) { (_, _, value: NSObject?, callOriginal) in
      optionalObjectHooks += 1
      receivedValues.append(value)
      callOriginal(value)
    }

    object.withOptionalObject(nil)
    object.withOptionalObject(objectValue)

    expect(optionalObjectHooks) == 2
    expect(object.optionalObjectCallCount) == 2
    expect(receivedValues.count) == 2
    expect(receivedValues[0]) == nil
    if let secondValue = receivedValues[1] {
      expect(secondValue === objectValue) == true
    } else {
      fail("Expected non-nil value for optional object")
    }

    token.cancel()
    observation.invalidate()
    expect(getClassName(object)) == originalClassName
  }

  func test_singleArg_optionalNumber_isIntercepted_KVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    var optionalNumberHooks = 0
    var receivedValues: [NSNumber?] = []
    let numberValue = NSNumber(value: true)

    let token = object.intercept(selector: #selector(TypeTestObject.withOptionalNumber(_:))) { (_, _, value: NSNumber?, callOriginal) in
      optionalNumberHooks += 1
      receivedValues.append(value)
      callOriginal(value)
    }

    object.withOptionalNumber(nil)
    object.withOptionalNumber(numberValue)

    expect(optionalNumberHooks) == 2
    expect(object.optionalNumberCallCount) == 2
    expect(receivedValues.count) == 2
    expect(receivedValues[0]) == nil
    if let secondValue = receivedValues[1] {
      expect(secondValue === numberValue) == true
    } else {
      fail("Expected non-nil value for optional number")
    }

    token.cancel()
    observation.invalidate()
    expect(getClassName(object)) == originalClassName
  }
}
