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

    private(set) var sizeCallCount = 0
    private(set) var rectCallCount = 0
    private(set) var objectCallCount = 0

    @objc dynamic func withSize(_ size: CGSize) {
      sizeCallCount += 1
    }

    @objc dynamic func withRect(_ rect: CGRect) {
      rectCallCount += 1
    }

    @objc dynamic func withObject(_ object: NSObject) {
      objectCallCount += 1
    }
  }

  // MARK: - Non-KVO

  func test_singleArg_types_areIntercepted_nonKVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    var sizeHooks = 0
    var rectHooks = 0
    var objectHooks = 0

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

    object.withSize(CGSize(width: 1, height: 2))
    object.withRect(CGRect(x: 1, y: 2, width: 3, height: 4))
    object.withObject(NSObject())

    expect(sizeHooks) == 1
    expect(rectHooks) == 1
    expect(objectHooks) == 1
    expect(object.sizeCallCount) == 1
    expect(object.rectCallCount) == 1
    expect(object.objectCallCount) == 1

    sizeToken.cancel()
    rectToken.cancel()
    objectToken.cancel()
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

  // MARK: - KVO

  func test_singleArg_types_areIntercepted_KVO() {
    let object = TypeTestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    var sizeHooks = 0
    var rectHooks = 0
    var objectHooks = 0

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

    object.withSize(CGSize(width: 1, height: 2))
    object.withRect(CGRect(x: 1, y: 2, width: 3, height: 4))
    object.withObject(NSObject())

    expect(sizeHooks) == 1
    expect(rectHooks) == 1
    expect(objectHooks) == 1
    expect(object.sizeCallCount) == 1
    expect(object.rectCallCount) == 1
    expect(object.objectCallCount) == 1

    sizeToken.cancel()
    rectToken.cancel()
    objectToken.cancel()

    observation.invalidate()
    expect(getClassName(object)) == originalClassName
  }
}
