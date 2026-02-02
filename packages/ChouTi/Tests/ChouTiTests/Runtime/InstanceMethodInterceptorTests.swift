//
//  InstanceMethodInterceptorTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2/1/26.
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

import Foundation
import ObjectiveC
import XCTest

import ChouTiTest

@testable import ChouTi

class InstanceMethodInterceptorTests: XCTestCase {

  @objc(ChouTiIMI_PrefixedTestObject)
  final class PrefixedTestObject: NSObject {

    @objc dynamic func foo() {}
  }

  final class TestObject: NSObject {

    private let lock = NSLock()

    @objc dynamic var value: Int = 0

    private(set) var fooCallCount = 0
    private(set) var barCallCount = 0
    private(set) var argCallCount = 0
    private(set) var returnCallCount = 0

    var fooClosure: (() -> Void)?

    @objc dynamic func foo() {
      lock.lock()
      fooCallCount += 1
      lock.unlock()
      fooClosure?()
    }

    @objc dynamic func bar() {
      lock.lock()
      barCallCount += 1
      lock.unlock()
    }

    @objc dynamic func withArg(_ value: Int) {
      lock.lock()
      argCallCount += 1
      lock.unlock()
    }

    @objc dynamic func returnsInt() -> Int {
      lock.lock()
      returnCallCount += 1
      lock.unlock()
      return 42
    }
  }

  // MARK: - Non-KVO

  func test_singleSelector_singleHook() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    // when intercept the method
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { theObject, selector, callOriginal in
      expect(theObject) === object
      expect(selector) == #selector(TestObject.foo)
      hookCount += 1
      callOriginal()
    }

    // then the class should be the dynamic subclass
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when call the method
    object.foo()

    // then the hook should be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 1

    // when cancel the token
    token.cancel()

    // then the class should be the original class
    expect(getClassName(object)) == originalClassName

    // when call the method again
    object.foo()

    // then the hook should not be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 2
  }

  func test_singleSelector_singleHook_executionOrder_originalFirst() {
    // given a non-KVO object
    let object = TestObject()

    var order: [Int] = []
    object.fooClosure = {
      order.append(1)
    }

    // when intercept the method
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      callOriginal() // call original first
      order.append(2)
    }

    // when call the method
    object.foo()

    // then the original should be called first
    expect(order) == [1, 2]
  }

  func test_singleSelector_singleHook_executionOrder_originalLast() {
    // given a non-KVO object
    let object = TestObject()

    var order: [Int] = []
    object.fooClosure = {
      order.append(1)
    }

    // when intercept the method
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(2)
      callOriginal() // call original last
    }

    // when call the method
    object.foo()

    // then the original should be called last
    expect(order) == [2, 1]
  }

  func test_singleSelector_multipleHooks_executionOrder() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    var order: [Int] = []
    object.fooClosure = {
      order.append(0)
    }

    // when intercept the method with multiple hooks
    let token1 = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(1)
      callOriginal()
    }
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // the class should be the dynamic subclass

    let token2 = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(2)
      callOriginal()
    }
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // no nested subclassing

    let token3 = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(3)
      callOriginal()
    }
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // no nested subclassing

    // when call the method
    object.foo()

    // then the hooks should be called in the order of the interceptors
    expect(order) == [1, 0, 2, 3]
    expect(object.fooCallCount) == 1 // the original should be called once

    // when cancel the tokens
    token1.cancel()
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // the class should not revert as there are still hooks registered

    token2.cancel()
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // the class should not revert as there are still hooks registered

    token3.cancel()
    expect(getClassName(object)) == originalClassName // the class should revert to the original class
  }

  func test_singleSelector_multipleHooks_executionOrder_originalInMiddle() {
    // given a non-KVO object
    let object = TestObject()

    var order: [Int] = []
    object.fooClosure = {
      order.append(0)
    }

    // when intercept the method with multiple hooks
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(1)
    }
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(2)
      callOriginal() // call original in middle
    }
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(3)
    }

    // when call the method
    object.foo()

    // then the hooks should be called in the order of the interceptors
    expect(order) == [1, 2, 0, 3] // the original method should be called in the middle
    expect(object.fooCallCount) == 1
  }

  func test_multipleSelectors() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    // when intercept the methods
    var fooHooks = 0
    let fooToken = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      fooHooks += 1
      callOriginal()
    }
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // the class should be the dynamic subclass

    // when intercept the other method
    var barHooks = 0
    let barToken = object.intercept(selector: #selector(TestObject.bar)) { _, _, callOriginal in
      barHooks += 1
      callOriginal()
    }
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // the class should be the same as the previous one

    // when call the methods
    object.foo()
    expect(fooHooks) == 1
    expect(barHooks) == 0
    expect(object.fooCallCount) == 1
    expect(object.barCallCount) == 0

    object.bar()
    expect(fooHooks) == 1
    expect(barHooks) == 1
    expect(object.fooCallCount) == 1
    expect(object.barCallCount) == 1

    // when cancel the tokens
    fooToken.cancel()
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)" // the class should not revert as there are still hooks registered
    barToken.cancel()
    expect(getClassName(object)) == originalClassName // the class should revert to the original class
  }

  func test_selectorWithArguments_isIgnored() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    var hookCount = 0
    var assertionMessage: String?
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      assertionMessage = message
    }
    defer {
      Assert.resetTestAssertionFailureHandler()
    }

    // when intercept the method with arguments
    object.intercept(selector: #selector(TestObject.withArg(_:))) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }

    // then the assertion should be thrown
    expect(assertionMessage) == "intercept only supports void methods with no args"
    expect(getClassName(object)) == originalClassName

    // when call the method with arguments
    object.withArg(2)

    // then the hook should not be called
    expect(hookCount) == 0
    expect(object.argCallCount) == 1
  }

  func test_selectorWithReturnValue_isIgnored() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    var hookCount = 0
    var assertionMessage: String?
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      assertionMessage = message
    }
    defer {
      Assert.resetTestAssertionFailureHandler()
    }

    // when intercept the method with a return value
    object.intercept(selector: #selector(TestObject.returnsInt)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }

    // then the assertion should be thrown
    expect(assertionMessage) == "intercept only supports void methods with no args"
    expect(getClassName(object)) == originalClassName

    // when call the method
    _ = object.returnsInt()

    // then the hook should not be called
    expect(hookCount) == 0
    expect(object.returnCallCount) == 1
  }

  func test_selectorNotFound_isIgnored() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)
    let selector = NSSelectorFromString("nonexistentSelector")

    var assertionMessage: String?
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      assertionMessage = message
    }
    defer {
      Assert.resetTestAssertionFailureHandler()
    }

    // when intercept a selector that does not exist
    object.intercept(selector: selector) { _, _, callOriginal in
      callOriginal()
    }

    // then the assertion should be thrown
    expect(assertionMessage) == "Failed to find method for selector"
    expect(getClassName(object)) == originalClassName
  }

  func test_intercept_cancel_without_invoke() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    // when intercept the method but never invoke it
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }

    // then the class should be the dynamic subclass
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when cancel the token
    token.cancel()

    // then the class should be the original class
    expect(getClassName(object)) == originalClassName

    // when call the method
    object.foo()
    // then the hook should not be called
    expect(hookCount) == 0
    expect(object.fooCallCount) == 1
  }

  func test_cancel_after_state_removed_isIgnored() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    // when intercept the method
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      callOriginal()
    }

    // then the class should be the dynamic subclass
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when remove associated state before cancelling
    objc_removeAssociatedObjects(object)

    // then cancelling should be ignored and not crash
    token.cancel()
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"
  }

  func test_invokeHooks_without_state_calls_original() {
    // given a non-KVO object
    let object = TestObject()

    // when intercept the method
    var hookCount = 0
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }

    // remove associated state so invokeHooks sees no state
    objc_removeAssociatedObjects(object)

    // when call the method
    object.foo()

    // then original should be called and hooks should not run
    expect(hookCount) == 0
    expect(object.fooCallCount) == 1
  }

  func test_invokeHooks_without_state_on_swizzled_subclass_calls_original() {
    // given a swizzled subclass created by another instance
    let object = TestObject()
    let subclassToken = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      callOriginal()
    }
    let subclassName = getClassName(object)
    guard let subclass = NSClassFromString(subclassName) else {
      fail("Failed to find subclass for swizzled class")
      return
    }

    // when another instance is forced onto the subclass without state
    let otherObject = TestObject()
    object_setClass(otherObject, subclass)

    // then calling the method should invoke the original via the no-state path
    otherObject.foo()
    expect(otherObject.fooCallCount) == 1

    // cleanup
    subclassToken.cancel()
  }

  func test_invokeHooks_reentrancy_calls_original_directly() {
    // given a non-KVO object
    let object = TestObject()

    // when intercept the method and re-enter the same selector
    var hookCount = 0
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      object.foo()
      callOriginal()
    }

    // when call the method
    object.foo()

    // then the hook should run once and original should be called twice
    expect(hookCount) == 1
    expect(object.fooCallCount) == 2
  }

  func test_concurrent_invocations_should_invoke_hooks_for_each_call() {
    // This test demonstrates a concurrency bug: the global reentrancy guard
    // causes hooks to be skipped for concurrent invocations on the same selector.
    let object = TestObject()

    // Semaphores to pause hooks so the second call overlaps.
    let hookEnteredFirst = DispatchSemaphore(value: 0)
    let hookEnteredSecond = DispatchSemaphore(value: 0)
    let hookRelease = DispatchSemaphore(value: 0)

    // Track completion of both async calls.
    let group = DispatchGroup()

    // Thread-safe hook counter.
    let lock = NSLock()
    var hookCount = 0

    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      lock.lock()
      hookCount += 1
      let currentCount = hookCount
      lock.unlock()

      // Signal that each hook started, then block it.
      if currentCount == 1 {
        hookEnteredFirst.signal()
      } else if currentCount == 2 {
        hookEnteredSecond.signal()
      }
      _ = hookRelease.wait(timeout: .now() + 2)

      callOriginal()
    }

    // First call: enters the hook and blocks.
    group.enter()
    DispatchQueue.global(qos: .userInitiated).async {
      object.foo()
      group.leave()
    }

    // Wait until the first hook is running so the next call overlaps.
    if hookEnteredFirst.wait(timeout: .now() + 2) == .timedOut {
      // Release in case a hook is blocked.
      hookRelease.signal()
      hookRelease.signal()
      token.cancel()
      fail("Timed out waiting for first hook to start")
      return
    }

    // Second call: should also run hooks even while the first is in progress.
    group.enter()
    DispatchQueue.global(qos: .userInitiated).async {
      object.foo()
      group.leave()
    }

    if hookEnteredSecond.wait(timeout: .now() + 2) == .timedOut {
      // Release in case a hook is blocked.
      hookRelease.signal()
      hookRelease.signal()
      token.cancel()
      fail("Timed out waiting for second hook to start")
      return
    }

    // Unblock both hooks and wait for both calls to finish.
    hookRelease.signal()
    hookRelease.signal()

    if group.wait(timeout: .now() + 2) == .timedOut {
      // Release in case any hook is blocked.
      hookRelease.signal()
      hookRelease.signal()
      token.cancel()
      fail("Timed out waiting for concurrent calls to finish")
      return
    }

    // Expected: both calls should invoke hooks and originals.
    expect(object.fooCallCount) == 2
    expect(hookCount) == 2
    token.cancel()
  }

  func test_intercept_on_prefixed_class_asserts_missing_method() {
    // given an object whose class name already has the interceptor prefix
    let object = PrefixedTestObject()
    let originalClassName = getClassName(object)

    // when intercept the method
    var assertionMessage: String?
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      assertionMessage = message
    }
    defer {
      Assert.resetTestAssertionFailureHandler()
    }

    var hookCount = 0
    let token = object.intercept(selector: #selector(PrefixedTestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }

    // then the assertion should be thrown
    expect(assertionMessage) == "Failed to find method for selector"

    // and the class should remain the same (no nested subclass)
    expect(getClassName(object)) == originalClassName

    // when call the method
    object.foo()
    expect(hookCount) == 0

    // when cancel the token
    token.cancel()
    expect(getClassName(object)) == originalClassName
  }

  // MARK: - KVO

  func test_KVO_singleSelector_singleHook_KVO_intercept_unintercept_unKVO() {
    // given a KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when intercept the method
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }
    // then the class should be still the KVO class
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the method
    object.foo()
    // then the hook should be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 1

    // when cancel the interception
    token.cancel()
    // then the class should be still the KVO class
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the method again
    object.foo()
    // then the hook should not be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 2

    // when invalidate KVO observation
    observation.invalidate()
    // then the class should be the original class
    expect(getClassName(object)) == originalClassName
  }

  func test_KVO_singleSelector_singleHook_executionOrder_originalFirst() {
    // given a KVO object
    let object = TestObject()

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    var order: [Int] = []
    object.fooClosure = {
      order.append(1)
    }

    // when intercept the method
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      callOriginal() // call original first
      order.append(2)
    }

    // when call the method
    object.foo()
    // then the original should be called first
    expect(order) == [1, 2]
  }

  func test_KVO_singleSelector_singleHook_executionOrder_originalLast() {
    // given a KVO object
    let object = TestObject()

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    var order: [Int] = []
    object.fooClosure = {
      order.append(1)
    }

    // when intercept the method
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(2)
      callOriginal() // call original last
    }

    // when call the method
    object.foo()
    // then the original should be called last
    expect(order) == [2, 1]
  }

  func test_KVO_singleSelector_multipleHooks_executionOrder() {
    // given a KVO object
    let object = TestObject()

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    var order: [Int] = []
    object.fooClosure = {
      order.append(0)
    }

    // when intercept the method with multiple hooks
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(1)
      callOriginal()
    }
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(2)
      callOriginal()
    }
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(3)
      callOriginal()
    }

    // when call the method
    object.foo()
    // then the hooks should be called in the order of the interceptors
    expect(order) == [1, 0, 2, 3]
  }

  func test_KVO_singleSelector_multipleHooks_executionOrder_originalInMiddle() {
    // given a KVO object
    let object = TestObject()

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    var order: [Int] = []
    object.fooClosure = {
      order.append(0)
    }

    // when intercept the method with multiple hooks
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(1)
    }
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(2)
      callOriginal() // call original in middle
    }
    object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      order.append(3)
    }

    // when call the method
    object.foo()
    // then the hooks should be called in the order of the interceptors
    expect(order) == [1, 2, 0, 3] // the original method should be called in the middle
  }

  func test_KVO_multipleSelectors() {
    // given a KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when intercept the methods
    var fooHooks = 0
    let fooToken = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      fooHooks += 1
      callOriginal()
    }
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when intercept the other method
    var barHooks = 0
    let barToken = object.intercept(selector: #selector(TestObject.bar)) { _, _, callOriginal in
      barHooks += 1
      callOriginal()
    }
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the methods
    object.foo()
    expect(fooHooks) == 1
    expect(barHooks) == 0
    expect(object.fooCallCount) == 1
    expect(object.barCallCount) == 0

    object.bar()
    expect(fooHooks) == 1
    expect(barHooks) == 1
    expect(object.fooCallCount) == 1
    expect(object.barCallCount) == 1

    // when cancel the tokens
    fooToken.cancel()
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    object.foo()
    expect(fooHooks) == 1
    expect(barHooks) == 1
    expect(object.fooCallCount) == 2
    expect(object.barCallCount) == 1

    barToken.cancel()
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    object.bar()
    expect(fooHooks) == 1
    expect(barHooks) == 1
    expect(object.fooCallCount) == 2
    expect(object.barCallCount) == 2

    // when invalidate KVO observation
    observation.invalidate()
    expect(getClassName(object)) == originalClassName
  }

  func test_KVO_selectorWithArguments_isIgnored() {
    // given a KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    var hookCount = 0
    var assertionMessage: String?
    Assert.setTestAssertionFailureHandler { message, _, _, _, _ in
      assertionMessage = message
    }
    defer {
      Assert.resetTestAssertionFailureHandler()
    }

    // when intercept the method with arguments
    object.intercept(selector: #selector(TestObject.withArg(_:))) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }

    // then the assertion should be thrown
    expect(assertionMessage) == "intercept only supports void methods with no args"
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the method with arguments
    object.withArg(2)

    // then the hook should not be called
    expect(hookCount) == 0
    expect(object.argCallCount) == 1
  }

  // MARK: - KVO + Intercept

  func test_intercept_KVO_then_unKVO_unintercept() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    // when intercept the method
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }
    // then the class should be the dynamic subclass
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when setup KVO observation
    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    // then the class should be the KVO class
    expect(getClassName(object)) == "NSKVONotifying_ChouTiIMI_\(originalClassName)"

    // when call the method
    object.foo()
    expect(hookCount) == 1
    expect(object.fooCallCount) == 1

    // when invalidate KVO observation
    observation.invalidate()
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when call the method again
    object.foo()
    expect(hookCount) == 2
    expect(object.fooCallCount) == 2

    // when cancel the interception
    token.cancel()
    // then the class should be the original class
    expect(getClassName(object)) == originalClassName

    // when call the method again
    object.foo()
    expect(hookCount) == 2
    expect(object.fooCallCount) == 3
  }

  func test_intercept_KVO_then_unintercept_unKVO() {
    // given a non-KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    // when intercept the method
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }
    // then the class should be the dynamic subclass
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when setup KVO observation
    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    // then the class should be the KVO class
    expect(getClassName(object)) == "NSKVONotifying_ChouTiIMI_\(originalClassName)"

    // when call the method
    object.foo()
    expect(hookCount) == 1
    expect(object.fooCallCount) == 1

    // when cancel the interception
    token.cancel()
    // then the class should still be the KVO class
    expect(getClassName(object)) == "NSKVONotifying_ChouTiIMI_\(originalClassName)"

    // when call the method again
    object.foo()
    // then the hook should not be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 2

    // when invalidate KVO observation
    observation.invalidate()
    // then the class should be the dynamic subclass
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when call the method again
    object.foo()
    // then the hook should not be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 3

    // when intercept another method
    hookCount = 0
    let anotherToken = object.intercept(selector: #selector(TestObject.bar)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }
    // then the class should still be the dynamic subclass (not reverted to the original class)
    expect(getClassName(object)) == "ChouTiIMI_\(originalClassName)"

    // when call the method
    object.bar()
    // then the hook should be called
    expect(hookCount) == 1
    expect(object.barCallCount) == 1

    // when cancel the interception
    anotherToken.cancel()
    // then the class should revert to the original class
    expect(getClassName(object)) == originalClassName

    // when call the method again
    object.bar()
    // then the hook should not be called
    expect(hookCount) == 1
    expect(object.barCallCount) == 2
  }

  func test_KVO_intercept_then_unintercept_unKVO() {
    // given a KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when intercept the method
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }
    // then the class should still be the KVO class
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the method
    object.foo()
    // then the hook should be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 1

    // when cancel the interception
    token.cancel()
    // then the class should still be the KVO class
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the method again
    object.foo()
    // then the hook should not be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 2

    // when invalidate KVO observation
    observation.invalidate()

    // then the class should be the original class
    expect(getClassName(object)) == originalClassName
  }

  func test_KVO_intercept_then_unKVO_unintercept() {
    // given a KVO object
    let object = TestObject()
    let originalClassName = getClassName(object)

    let observation = object.observe(\.value, options: [.new]) { _, _ in }
    _ = observation

    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when intercept the method
    var hookCount = 0
    let token = object.intercept(selector: #selector(TestObject.foo)) { _, _, callOriginal in
      hookCount += 1
      callOriginal()
    }
    // then the class should still be the KVO class
    expect(getClassName(object)) == "NSKVONotifying_\(originalClassName)"

    // when call the method
    object.foo()
    // then the hook should be called
    expect(hookCount) == 1
    expect(object.fooCallCount) == 1

    // when invalidate KVO observation
    observation.invalidate()

    // then the class should be the original class
    expect(getClassName(object)) == originalClassName

    // when call the method again
    object.foo()
    // then the hook should still be called
    expect(hookCount) == 2
    expect(object.fooCallCount) == 2

    // when cancel the interception
    token.cancel()
    // then the class should still be the original class
    expect(getClassName(object)) == originalClassName

    // when call the method again
    object.foo()
    // then the hook should not be called
    expect(hookCount) == 2
    expect(object.fooCallCount) == 3
  }

  func test_KVO_dealloc_without_unintercept_restores_originalIMP() {
    // capture the original IMP so we can verify it is restored after cleanup.
    let selector = #selector(TestObject.foo)
    guard let originalIMP = methodImplementation(TestObject.self, selector) else {
      fail("Failed to get original IMP")
      return
    }

    // keep tokens alive so cancellation does not happen before deallocation.
    var tokens: [CancellableToken] = []

    // create the second instance first and keep it alive to ensure the swizzle stays active
    // after the first instance deallocates.
    var object2: TestObject! = TestObject()
    weak var weakObject2 = object2
    var observation2: NSKeyValueObservation? = object2?.observe(\.value, options: [.new]) { _, _ in }
    _ = observation2
    let token2 = object2.intercept(selector: selector) { _, _, callOriginal in
      callOriginal()
    }
    tokens.append(token2)

    // create a first instance inside an autoreleasepool and let it deallocate without cancelling.
    weak var weakObject1: TestObject?
    autoreleasepool {
      let object1 = TestObject()
      weakObject1 = object1
      let observation1 = object1.observe(\.value, options: [.new]) { _, _ in }
      _ = observation1
      let token1 = object1.intercept(selector: selector) { _, _, callOriginal in
        callOriginal()
      }
      tokens.append(token1)
    }

    // then the first instance should be deallocated.
    expect(weakObject1) == nil

    // then the swizzle should still be active because object2 is alive.
    if let currentIMP = methodImplementation(TestObject.self, selector) {
      expect(currentIMP) != originalIMP
    }

    // now drop the last instance. then the original IMP should be restored.
    observation2 = nil
    object2 = nil
    expect(weakObject2) == nil

    if let restoredIMP = methodImplementation(TestObject.self, selector) {
      expect(restoredIMP) == originalIMP
    }
  }
}

private func methodImplementation(_ cls: AnyClass, _ selector: Selector) -> IMP? {
  guard let method = class_getInstanceMethod(cls, selector) else {
    return nil
  }
  return method_getImplementation(method)
}
