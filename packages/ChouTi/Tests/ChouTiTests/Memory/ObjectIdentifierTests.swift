//
//  ObjectIdentifierTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/30/22.
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

import ChouTi

class ObjectIdentifierTests: XCTestCase {

  private class FooObject {
    let foo: Int = 0
  }

  private struct FooStrut {
    let foo: Int = 0
  }

  func test() {
    let object1 = FooObject()
    let object2 = FooObject()

    expect("\(ChouTi.rawPointer(object1))") != "\(ChouTi.rawPointer(object2))"

    expect(memoryAddress(ChouTi.rawPointer(object1))) != 0

    var struct1 = FooStrut()
    var struct1Copy = struct1
    var struct2 = FooStrut()

    expect(memoryAddress(&struct1)) == memoryAddress(&struct1)
    expect(memoryAddress(&struct1)) != memoryAddress(&struct1Copy)
    expect(memoryAddress(&struct1)) != memoryAddress(&struct2)

    // print(_memoryAddress(&struct1))
    // print(_memoryAddress(&struct1Copy))
    // print(_memoryAddress(&struct2))
    // 6132956592
    // 6132956584
    // 6132956576

    let object = NSObject()
    expect(object.objectIdentifier()) == ObjectIdentifier(object)
    expect(object.objectIdentifier()) != self.objectIdentifier()

    expect(object.rawPointer()) == Unmanaged.passUnretained(object).toOpaque()
    expect(object.rawPointer()) != self.rawPointer()
  }

  func test_memoryAddressString() {
    #if canImport(AppKit)
    let path = NSBezierPath()
    expect(String(describing: path).hasPrefix("Path <\(memoryAddressString(path))>")) == true
    expect(String(describing: path).hasPrefix("Path <\(memoryAddressString(path.rawPointer()))>")) == true
    expect(String(describing: path).hasPrefix("Path <0x\(String(Int(bitPattern: Unmanaged.passUnretained(path).toOpaque()), radix: 16))>")) == true
    expect(String(describing: path).hasPrefix("Path <0x\(String(memoryAddress(ChouTi.rawPointer(path)), radix: 16))>")) == true
    #endif

    #if canImport(UIKit)
    let path = UIBezierPath()
    expect(String(describing: path).hasPrefix("<UIBezierPath: \(memoryAddressString(path));")) == true
    expect(String(describing: path).hasPrefix("<UIBezierPath: \(memoryAddressString(path.rawPointer()));")) == true
    expect(String(describing: path).hasPrefix("<UIBezierPath: 0x\(String(Int(bitPattern: Unmanaged.passUnretained(path).toOpaque()), radix: 16));")) == true
    expect(String(describing: path).hasPrefix("<UIBezierPath: 0x\(String(memoryAddress(ChouTi.rawPointer(path)), radix: 16));")) == true
    #endif
  }
}
