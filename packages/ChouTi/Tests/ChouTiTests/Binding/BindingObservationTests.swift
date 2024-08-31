//
//  BindingObservationTests.swift
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
@testable import ChouTi

class BindingObservationTests: XCTestCase {

  func test_observation() {
    let binding = Binding(0)
    let observation = binding.observe { value in
      print("Value changed to \(value)")
    }
    binding.value = 1
    observation.cancel()
  }

  func test_empty_AggregatedObservation() {
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "AggregatedBindingObservation must have at least one observation."
    }

    let observation = AggregatedBindingObservation(observations: [])
    expect(observation.isPaused) == false

    Assert.resetTestAssertionFailureHandler()
  }
}