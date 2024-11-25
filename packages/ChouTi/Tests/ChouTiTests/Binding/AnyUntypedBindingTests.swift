//
//  AnyUntypedBindingTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/1/24.
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

import Combine

import ChouTiTest

import ChouTi

class AnyUntypedBindingTests: XCTestCase {

  private var binding: Binding<String>!
  private var anyBinding: AnyUntypedBinding!

  override func setUp() {
    super.setUp()
    binding = Binding<String>("1")
    anyBinding = binding.eraseToAnyUntypedBinding()
  }

  override func tearDown() {
    binding = nil
    anyBinding = nil
    super.tearDown()
  }

  func test_init() {
    let anyBinding = AnyUntypedBinding(binding)
    expect(DynamicLookup(anyBinding).keyPath("baseAsHashable")) === binding

    let anyBinding2 = AnyUntypedBinding(anyBinding)
    expect(DynamicLookup(anyBinding2).keyPath("baseAsHashable")) === binding
  }

  func testValue() throws {
    expect(anyBinding.value as? String) == "1"
    binding.value = "2"
    expect(anyBinding.value as? String) == "2"
  }

  func testObserve() {
    let expectation = self.expectation(description: "AnyBinding")
    let observation = anyBinding.observe { value in
      expect(value as? String) == "2"
      expectation.fulfill()
    }
    binding.value = "2"
    wait(for: [expectation], timeout: 1)
    observation.cancel()
  }

  func testObserveWithCancel() throws {
    var received: [String] = []
    let observation = anyBinding.observe { value, cancel in
      received.append(value as? String ?? "")
      cancel()
    }
    _ = observation
    binding.value = "2"
    binding.value = "3"
    expect(received) == ["2"]
  }

  func testPublisher() throws {
    let expectation = XCTestExpectation(description: "AnyBinding")
    let cancellable = try anyBinding.unwrap().publisher.sink { (value: Any) in
      expect(value as? String) == "1"
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1)
    cancellable.cancel()
  }

  func test_duplicateAnyBinding() {
    let anyBinding1 = anyBinding.eraseToAnyUntypedBinding()
    expect(anyBinding1) === anyBinding
  }

  func testHashable() {
    // given
    let anyBinding1 = AnyUntypedBinding(binding)
    let anyBinding2 = AnyUntypedBinding(binding)

    // then
    expect(anyBinding1) == anyBinding2
    expect(anyBinding1.hashValue) == anyBinding2.hashValue

    expect(anyBinding1.hashValue) != binding.hashValue
    expect(anyBinding2.hashValue) != binding.hashValue

    // given
    // redundant wrapping
    let anyBinding3 = AnyUntypedBinding(binding).eraseToAnyUntypedBinding()

    // then
    expect(anyBinding3) == anyBinding1
    expect(anyBinding3) == anyBinding2
    expect(anyBinding3.hashValue) == anyBinding1.hashValue
    expect(anyBinding3.hashValue) == anyBinding2.hashValue

    expect(anyBinding3.hashValue) != binding.hashValue
  }
}
