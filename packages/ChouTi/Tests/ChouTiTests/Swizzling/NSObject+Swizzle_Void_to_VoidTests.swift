//
//  NSObject+Swizzle_Void_to_VoidTests.swift
//  ChouTi
//
//  Created by Honghao on 5/16/25.
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

import ChouTi

class NSObject_Swizzle_Void_to_VoidTests: XCTestCase {

  #if !os(watchOS)
  private class TestLayer: CALayer {

    var didLayoutSublayersCallCount = 0

    override func layoutSublayers() {
      super.layoutSublayers()
      didLayoutSublayersCallCount += 1
    }
  }

  func test_inject_layer() {
    var layer: TestLayer! = TestLayer()

    let className = getClassName(layer)

    // inject layoutSublayers first time
    var layoutSublayersCallCount = 0
    layer.inject(selector: #selector(TestLayer.layoutSublayers), block: { [weak layer] object in
      expect(object) === layer
      layoutSublayersCallCount += 1
    })

    // check the host object is subclassed
    let memoryAddress = layer.rawPointer()
    let layoutSublayersSubclassName = "\(className)_chouti_\(memoryAddress)_layoutSublayers"
    expect(getClassName(layer)) == layoutSublayersSubclassName
    expect(NSClassFromString(layoutSublayersSubclassName)) != nil

    // check the block is called
    layer.layoutSublayers()
    expect(layer.didLayoutSublayersCallCount) == 1
    expect(layoutSublayersCallCount) == 1

    layer.layoutSublayers()
    expect(layer.didLayoutSublayersCallCount) == 2
    expect(layoutSublayersCallCount) == 2

    // inject layoutSublayers again
    var secondLayoutSublayersCallCount = 0
    layer.inject(selector: #selector(TestLayer.layoutSublayers), block: { layer in
      secondLayoutSublayersCallCount += 1
    })

    // check the host object still has the same subclass
    expect(getClassName(layer)) == layoutSublayersSubclassName

    // check the block is called
    layer.layoutSublayers()
    expect(layer.didLayoutSublayersCallCount) == 3
    expect(layoutSublayersCallCount) == 3
    expect(secondLayoutSublayersCallCount) == 1

    // inject display
    var displayCallCount = 0
    let token = layer.inject(selector: #selector(CALayer.display), block: { layer in
      displayCallCount += 1
    })

    // check the host object is subclassed again
    let displaySubclassName = "\(className)_chouti_\(memoryAddress)_layoutSublayers_chouti_\(memoryAddress)_display"
    expect(getClassName(layer)) == displaySubclassName
    expect(NSClassFromString(displaySubclassName)) != nil

    // check the block is called
    layer.display()
    expect(displayCallCount) == 1

    layer.display()
    expect(displayCallCount) == 2

    // cancel the injection
    token?.cancel()

    // check the block is not called
    layer.display()
    expect(displayCallCount) == 2

    // check subclass is removed on deallocation
    layer = nil
    wait(timeout: 0.01)
    expect(NSClassFromString(layoutSublayersSubclassName)) == nil
    expect(NSClassFromString(displaySubclassName)) == nil
  }
  #endif

  private class TestObject: NSObject {

    var testMethodCallCount = 0

    @objc dynamic func testMethod() {
      testMethodCallCount += 1
    }

    @objc dynamic func testMethod2() {}
  }

  func test_inject() {
    var object: TestObject! = TestObject()

    let className = getClassName(object)

    // inject layoutSublayers first time
    var testMethodCallCount = 0
    object.inject(selector: #selector(TestObject.testMethod), block: { [weak object] theObject in
      expect(object) === theObject
      testMethodCallCount += 1
    })

    // check the host object is subclassed
    let memoryAddress = object.rawPointer()
    let testMethodSubclassName = "\(className)_chouti_\(memoryAddress)_testMethod"
    expect(getClassName(object)) == testMethodSubclassName
    expect(NSClassFromString(testMethodSubclassName)) != nil

    // check the block is called
    object.testMethod()
    expect(object.testMethodCallCount) == 1
    expect(testMethodCallCount) == 1

    object.testMethod()
    expect(object.testMethodCallCount) == 2
    expect(testMethodCallCount) == 2

    // inject layoutSublayers again
    var secondTestMethodCallCount = 0
    object.inject(selector: #selector(TestObject.testMethod), block: { object in
      secondTestMethodCallCount += 1
    })

    // check the host object still has the same subclass
    expect(getClassName(object)) == testMethodSubclassName

    // check the block is called
    object.testMethod()
    expect(object.testMethodCallCount) == 3
    expect(testMethodCallCount) == 3
    expect(secondTestMethodCallCount) == 1

    // inject display
    var testMethod2CallCount = 0
    let token = object.inject(selector: #selector(TestObject.testMethod2), block: { object in
      testMethod2CallCount += 1
    })

    // check the host object is subclassed again
    let testMethod2SubclassName = "\(className)_chouti_\(memoryAddress)_testMethod_chouti_\(memoryAddress)_testMethod2"
    expect(getClassName(object)) == testMethod2SubclassName
    expect(NSClassFromString(testMethod2SubclassName)) != nil

    // check the block is called
    object.testMethod2()
    expect(testMethod2CallCount) == 1

    object.testMethod2()
    expect(testMethod2CallCount) == 2

    // cancel the injection
    token?.cancel()

    // check the block is not called
    object.testMethod2()
    expect(testMethod2CallCount) == 2

    // check subclass is removed on deallocation
    object = nil
    wait(timeout: 0.01)
    expect(NSClassFromString(testMethodSubclassName)) == nil
    expect(NSClassFromString(testMethod2SubclassName)) == nil
  }
}
