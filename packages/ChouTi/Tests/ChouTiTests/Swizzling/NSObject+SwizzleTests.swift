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

    // inject layoutSublayers first time
    var layoutSublayersCallCount = 0
    layer.inject(selector: #selector(TestLayer.layoutSublayers), block: { [weak layer] object in
      expect(object) === layer
      layoutSublayersCallCount += 1
    })

    // check the host object is subclassed
    let memoryAddress = layer.rawPointer()
    let layoutSublayersSubclassName = "\(className)_chouti_\(memoryAddress)_layoutSublayers"
    expect(layer.className) == layoutSublayersSubclassName
    expect(NSClassFromString(layoutSublayersSubclassName)) != nil

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
    expect(layer.className) == layoutSublayersSubclassName

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
    expect(layer.className) == displaySubclassName
    expect(NSClassFromString(displaySubclassName)) != nil

    layer.display()
    expect(displayCallCount) == 1

    layer.display()
    expect(displayCallCount) == 2

    // cancel the injection
    token?.cancel()

    layer.display()
    expect(displayCallCount) == 2

    // check subclass is removed on deallocation
    layer = nil
    wait(timeout: 0.01)
    expect(NSClassFromString(layoutSublayersSubclassName)) == nil
    expect(NSClassFromString(displaySubclassName)) == nil
  }
}

private class TestLayer: CALayer {

  var didLayoutSublayersCallCount = 0

  override func layoutSublayers() {
    super.layoutSublayers()
    didLayoutSublayersCallCount += 1
  }
}
