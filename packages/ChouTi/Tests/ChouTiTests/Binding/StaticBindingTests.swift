//
//  StaticBindingTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/30/24.
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
import Combine

class StaticBindingTests: XCTestCase {

  private var cancellableSet: Set<AnyCancellable> = []

  func test_staticBinding_noEmit() {
    let binding = StaticBinding("fixed")

    expect(binding.value) == "fixed"

    var called: Bool?
    binding
      .observe { value, _ in
        called = true
      }
      .store(in: self)

    expect(binding.test_registered_observations.count) == 1

    expect(called) == nil

    binding
      .observe { value in
        called = true
      }
      .store(in: self)

    expect(binding.test_registered_observations.count) == 2

    expect(called) == nil
  }

  func test_staticBinding_emitCurrentValue() {
    let binding = StaticBinding("fixed")

    expect(binding.value) == "fixed"

    var emittedValue: String?
    binding.emitCurrentValue()
      .observe { value, _ in
        emittedValue = value
      }
      .store(in: self)

    expect(binding.test_registered_observations.count) == 1

    expect(emittedValue) == "fixed"
  }

  func test_staticBinding_publisher() {
    let binding = StaticBinding("fixed")

    var receivedValue: String?
    binding.publisher
      .sink {
        receivedValue = $0
      }.store(in: &cancellableSet)

    expect(receivedValue) == "fixed"
  }

  func test_staticBinding_noEmit_removeObservation() {
    let binding = StaticBinding("fixed")

    expect(binding.value) == "fixed"

    var called: Bool?
    var observation: BindingObservation? = binding
      .observe { value, _ in
        called = true
      }
    _ = observation

    expect(binding.test_registered_observations.count) == 1

    expect(called) == nil

    observation = nil

    expect(binding.test_registered_observations.count) == 0
  }

  func test_staticBinding_expressible() {
    let voidBinding = StaticBinding<Void>()
    _ = voidBinding

    let boolBinding: StaticBinding<Bool> = true
    expect(boolBinding.value) == true

    let intBinding: StaticBinding<Int> = 98
    expect(intBinding.value) == 98

    let doubleBinding: StaticBinding<Double> = 98.89
    expect(doubleBinding.value) == 98.89
  }

  func test_staticBinding_DeallocationNotifiable() {
    var binding: StaticBinding<Bool>! = StaticBinding(false)

    var called: Bool?
    binding.onDeallocate {
      called = true
    }

    binding = nil
    expect(called) == true
  }

  func test_staticBinding_DeallocationNotifiable_remove() {
    var binding: StaticBinding<Bool>! = StaticBinding(false)

    var called: Bool?
    let token = binding.onDeallocate {
      called = true
    }

    token.cancel()

    binding = nil
    expect(called) == nil
  }

  func test_expressibleByStringLiteral() {
    let binding: StaticBinding<String> = "Hello, world!"
    expect(binding.value) == "Hello, world!"
  }

  func test_expressibleByUnicodeScalarLiteral() {
    do {
      let binding = StaticBinding<String>(unicodeScalarLiteral: "a")
      expect(binding.value) == "a"
    }
    do {
      let binding = StaticBinding<String>(unicodeScalarLiteral: "\u{1F600}")
      expect(binding.value) == "😀"
    }
    do {
      let binding = StaticBinding<String>(unicodeScalarLiteral: "👨‍👩‍👧‍👦")
      expect(binding.value) == "👨‍👩‍👧‍👦"
    }
    do {
      let binding = StaticBinding<String>(unicodeScalarLiteral: "こんにちは世界")
      expect(binding.value) == "こんにちは世界"
    }
    do {
      let binding = StaticBinding<String>(unicodeScalarLiteral: """
      This is a
      multiline
      string
      """)
      expect(binding.value) == "This is a\nmultiline\nstring"
    }
  }

  func test_expressibleByExtendedGraphemeClusterLiteral() {
    let binding = StaticBinding<String>(extendedGraphemeClusterLiteral: "a")
    expect(binding.value) == "a"
  }
}
