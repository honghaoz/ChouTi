//
//  TriggerTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/5/21.
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

class TriggerTests: XCTestCase {

  func test() {
    let trigger = Trigger<Int>()

    expect(trigger.hasReaction()) == false

    var reactedNumber: Int?
    trigger.setReaction { context in
      reactedNumber = context
    }
    expect(reactedNumber) == nil
    expect(trigger.hasReaction()) == true

    trigger.fire(with: 2)
    expect(reactedNumber) == 2

    trigger.removeReaction()
    expect(trigger.hasReaction()) == false
  }

  func test_setReactionTwice() {
    let trigger = Trigger<Int>()

    trigger.setReaction { _ in }

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Reaction block is already set"
    }

    trigger.setReaction { _ in }

    Assert.resetTestAssertionFailureHandler()
  }

  func test_publisher() {
    let trigger = Trigger<Int>()
    var receivedValue: Int?
    let cancellable = trigger.publisher.sink { value in
      receivedValue = value
    }

    // no value is emitted immediately
    expect(receivedValue) == nil

    trigger.fire(with: 2)
    expect(receivedValue) == 2

    trigger.fire(with: 3)
    expect(receivedValue) == 3
  }

  func testSubscribeToBinding() {
    let binding = Binding<String>("2")
    let trigger = Trigger<Int>()

    var reactedNumber: Int?
    trigger.setReaction { context in
      reactedNumber = context
    }
    expect(reactedNumber) == nil
    expect(binding.test_registered_observations.count) == 0

    trigger.subscribe(to: binding, map: { Int($0) ?? -1 })
    expect(reactedNumber) == nil
    expect(binding.test_registered_observations.count) == 1

    binding.value = "3"
    expect(reactedNumber) == 3

    trigger.disconnectFromBinding()
    expect(binding.test_registered_observations.count) == 0

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Trigger is not connected to a binding"
    }
    trigger.disconnectFromBinding()
    Assert.resetTestAssertionFailureHandler()
  }

  func testSubscribeToBinding_releaseTrigger() {
    let binding = Binding<String>("2")
    var trigger: Trigger<Int>? = Trigger<Int>()

    var reactedNumber: Int?
    trigger?.setReaction { context in
      reactedNumber = context
    }
    expect(reactedNumber) == nil
    expect(binding.test_registered_observations.count) == 0

    trigger?.subscribe(to: binding, map: { Int($0) ?? -1 })
    expect(reactedNumber) == nil
    expect(binding.test_registered_observations.count) == 1

    binding.value = "3"
    expect(reactedNumber) == 3

    trigger = nil
    expect(binding.test_registered_observations.count) == 0
  }

  func testSubscribeToBindingFireImmediately() {
    let binding = Binding<Int>(2)
    let trigger = Trigger<Int>()

    var reactedNumber: Int?
    trigger.setReaction { context in
      reactedNumber = context
    }
    expect(reactedNumber) == nil

    trigger.subscribe(to: binding.emitCurrentValue())
    expect(reactedNumber) == 2
  }

  func testVoidTrigger() {
    let trigger = Trigger<Void>()

    var isCalled: Bool = false
    trigger.setReaction {
      isCalled = true
    }
    expect(isCalled) == false

    trigger.fire()
    expect(isCalled) == true

    // --- binding ---
    isCalled = false
    let binding = Binding<Int>(2)
    trigger.subscribe(to: binding)
    expect(isCalled) == false

    // --- binding, fire immediately ---
    isCalled = false
    trigger.subscribe(to: binding.emitCurrentValue())
    expect(isCalled) == true

    isCalled = false
    binding.value = 9
    expect(isCalled) == true
  }

  func testVoidTriggerWithBinding() {
    let binding = Binding<Int>(2)
    let trigger = Trigger<Void>(binding: binding)

    var isCalled: Bool = false
    trigger.setReaction {
      isCalled = true
    }
    expect(isCalled) == false

    binding.value = 3
    expect(isCalled) == true
  }

  func testHashable() {
    let trigger1 = Trigger<Void>()
    let trigger2 = Trigger<Void>()

    expect(trigger1.hashValue) == trigger1.hashValue
    expect(trigger1.hashValue) != trigger2.hashValue
  }

  func testEquatable() {
    let trigger1 = Trigger<Void>()
    let trigger2 = Trigger<Void>()

    expect(trigger1) != trigger2
    expect(trigger1) == trigger1
  }
}
