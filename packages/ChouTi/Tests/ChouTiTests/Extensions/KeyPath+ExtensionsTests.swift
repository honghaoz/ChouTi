//
//  KeyPath+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/1/24.
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

import ChouTi
import ChouTiTest
import QuartzCore

class KeyPath_ExtensionsTests: XCTestCase {

  class TestObject: NSObject {

    dynamic var name: Name = Name(first: "", last: "")
    @objc dynamic var name2: Name = Name(first: "", last: "")

    class Name: NSObject {
      @objc dynamic var first: String = ""
      @objc dynamic var last: String = ""

      init(first: String, last: String) {
        self.first = first
        self.last = last
      }
    }
  }

  func test_keyPathStringValue() {
    expect((\NSObject.description as KeyPath).stringValue) == "description"
    expect((\CABasicAnimation.fromValue as KeyPath).stringValue) == "fromValue"
    expect((\CALayer.bounds.size.width).stringValue) == "bounds.size.width"
    expect((\CALayer.bounds.size.height).stringValue) == "bounds.size.height"
    expect((\CALayer.shadowColor).stringValue) == "shadowColor"
    expect((\CALayer.shadowColor?.alpha).stringValue) == "shadowColor?.alpha?"

    let layer = CALayer()
    layer.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
    layer.shadowColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)

    expect(layer.value(forKeyPath: (\CALayer.bounds.size.width).stringValue) as? CGFloat) == 100
    expect(layer.value(forKeyPath: (\CALayer.bounds.size.height).stringValue) as? CGFloat) == 100
    expect(layer.value(forKeyPath: (\CALayer.bounds.size).stringValue) as? CGSize) == CGSize(width: 100, height: 100)
    expect(layer.value(forKeyPath: (\CALayer.shadowColor).stringValue) as! CGColor) == CGColor(red: 1, green: 0, blue: 0, alpha: 1) // swiftlint:disable:this force_cast

    expect((\TestObject.name as KeyPath).stringValue) == "name"
    expect((\TestObject.name.first as KeyPath).stringValue) == "name.first"
    expect((\TestObject.name.last as KeyPath).stringValue) == "name.last"

    expect((\TestObject.name2 as KeyPath).stringValue) == "name2"
    expect((\TestObject.name2.first as KeyPath).stringValue) == "name2.first"
    expect((\TestObject.name2.last as KeyPath).stringValue) == "name2.last"
  }
}
