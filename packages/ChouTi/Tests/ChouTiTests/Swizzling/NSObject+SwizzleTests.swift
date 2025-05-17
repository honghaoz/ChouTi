//
//  NSObject+SwizzleTests.swift
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

class NSObject_SwizzleTests: XCTestCase {

  func test_inject() {
    var layer: TestLayer! = TestLayer()

    let className = layer.className

    var callCount = 0
    layer.inject(selector: #selector(TestLayer.layoutSublayers), block: { [weak layer] object in
      expect(object) === layer
      callCount += 1
    })

    let a = CALayer.layoutSublayers

    // check subclass is created
    let memoryAddress = layer.rawPointer()
    let subclassName = "\(className)_chouti_layoutSublayers_\(memoryAddress)"
    expect(layer.className) == subclassName
    expect(NSClassFromString(subclassName)) != nil

    layer.layoutSublayers()
    expect(layer.didLayoutSublayersCallCount) == 1
    expect(callCount) == 1

    layer.layoutSublayers()
    expect(layer.didLayoutSublayersCallCount) == 2
    expect(callCount) == 2

    // inject again
    var secondCallCount = 0
    layer.inject(selector: #selector(TestLayer.layoutSublayers), block: { layer in
      secondCallCount += 1
    })

    // check another subclass is created
    let anotherSubclassName = "\(className)_chouti_layoutSublayers_\(memoryAddress)_chouti_layoutSublayers_\(memoryAddress)"
    expect(layer.className) == anotherSubclassName
    expect(NSClassFromString(anotherSubclassName)) != nil

    layer.layoutSublayers()
    expect(layer.didLayoutSublayersCallCount) == 3
    expect(callCount) == 3
    expect(secondCallCount) == 1

    // check subclass is removed on deallocation
    layer = nil
    expect(NSClassFromString(subclassName)) == nil
    expect(NSClassFromString(anotherSubclassName)) == nil
  }
}

private class TestLayer: CALayer {

  var didLayoutSublayersCallCount = 0

  override func layoutSublayers() {
    super.layoutSublayers()
    didLayoutSublayersCallCount += 1
  }
}
