//
//  BindingType+TypeEraseWrapperBaseTypeTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/5/24.
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

class BindingType_TypeEraseWrapperBaseTypeTests: XCTestCase {

  func testCasting() {
    let binding = Binding(true)
    expect(binding.as(Binding<Bool>.self)) != nil
    if #available(iOS 16.0.0, macOS 13.0, tvOS 16.0, *) {
      expect(binding.as((any BindingType<Bool>).self)) != nil
    }

    let anyBinding: any BindingType<Bool> = AnyBinding(binding)
    expect(anyBinding as? Binding<Bool>) == nil
    expect(anyBinding.as(Binding<Bool>.self)) != nil
    if #available(iOS 16.0.0, macOS 13.0, tvOS 16.0, *) {
      expect(anyBinding.as((any BindingType<Bool>).self)) != nil
    }

    // failed casting
    expect(binding.as(Binding<Int>.self)) == nil
  }
}
