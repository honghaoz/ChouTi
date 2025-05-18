//
//  NSObject+Swizzle_Void_to_SomeTests.swift
//  ChouTi
//
//  Created by Honghao on 5/17/25.
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

import QuartzCore

import ChouTiTest

@testable import ChouTi

class NSObject_Swizzle_Void_to_SomeTests: XCTestCase {

  private class TestObject: NSObject {

    var _value: Int = 0

    @objc dynamic func getValue() -> Int {
      _value
    }
  }

  func test_override() {
    var object: TestObject! = TestObject()

    let className = getClassName(object)

    // inject layoutSublayers first time
    var overrideCallCount = 0

    object.override(selector: #selector(TestObject.getValue)) { [weak object] theObject, invokeSuperMethod in
      expect(object) === theObject
      overrideCallCount += 1
      return invokeSuperMethod() + 2
    }

    // check the host object is subclassed
    let memoryAddress = object.rawPointer()
    let subclassName = "\(className)_chouti_\(memoryAddress)_getValue"
    expect(getClassName(object)) == subclassName
    expect(NSClassFromString(subclassName)) != nil

    expect(object.getValue()) == 2
    expect(overrideCallCount) == 1

    // check subclass is removed on deallocation
    object = nil
    wait(timeout: 0.01)
    expect(NSClassFromString(subclassName)) == nil
  }
}
