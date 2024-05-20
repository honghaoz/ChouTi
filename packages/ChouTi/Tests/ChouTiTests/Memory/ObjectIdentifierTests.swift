//
//  ObjectIdentifierTests.swift
//
//  Created by Honghao Zhang on 3/30/22.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
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

    // var struct1 = FooStrut()
    // var struct1Copy = struct1
    // var struct2 = FooStrut()
    // print(_memoryAddress(&struct1))
    // print(_memoryAddress(&struct1Copy))
    // print(_memoryAddress(&struct2))
    // 6132956592
    // 6132956584
    // 6132956576
  }
}
