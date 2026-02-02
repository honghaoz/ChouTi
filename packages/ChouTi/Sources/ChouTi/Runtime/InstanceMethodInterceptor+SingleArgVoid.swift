//
//  InstanceMethodInterceptor+SingleArgVoid.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2/2/26.
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

extension InstanceMethodInterceptor {

  private typealias VoidMethodWithIntIMP = @convention(c) (AnyObject, Selector, Int) -> Void
  private typealias VoidMethodWithCGSizeIMP = @convention(c) (AnyObject, Selector, CGSize) -> Void
  private typealias VoidMethodWithCGRectIMP = @convention(c) (AnyObject, Selector, CGRect) -> Void
  private typealias VoidMethodWithObjectIMP = @convention(c) (AnyObject, Selector, AnyObject) -> Void

  /// Intercepts a void, single-argument instance method on the given object.
  static func intercept<Arg>(_ object: AnyObject, selector: Selector, block: @escaping InstanceMethodInvokeBlockWithArg<Arg>) -> CancellableToken {
    let erasedBlock: InstanceMethodInvokeBlockWithArgAny = { object, selector, arg, callOriginal in
      guard let typedArg = arg as? Arg else {
        ChouTi.assertFailure("intercept arg type mismatch", metadata: [
          "selector": NSStringFromSelector(selector),
          "expected": String(describing: Arg.self),
          "actual": String(describing: type(of: arg)),
        ])
        return
      }
      let callOriginalTyped: (Arg) -> Void = { value in
        callOriginal(value)
      }
      block(object, selector, typedArg, callOriginalTyped)
    }

    if Arg.self == Int.self {
      return interceptSingleArg(
        object,
        selector: selector,
        block: erasedBlock,
        addSubclassOverride: addSubclassOverrideWithIntIfNeeded,
        swizzleOriginalMethod: swizzleOriginalMethodWithInt
      )
    }

    if Arg.self == CGSize.self {
      return interceptSingleArg(
        object,
        selector: selector,
        block: erasedBlock,
        addSubclassOverride: addSubclassOverrideWithCGSizeIfNeeded,
        swizzleOriginalMethod: swizzleOriginalMethodWithCGSize
      )
    }

    if Arg.self == CGRect.self {
      return interceptSingleArg(
        object,
        selector: selector,
        block: erasedBlock,
        addSubclassOverride: addSubclassOverrideWithCGRectIfNeeded,
        swizzleOriginalMethod: swizzleOriginalMethodWithCGRect
      )
    }

    if Arg.self is AnyObject.Type {
      return interceptSingleArg(
        object,
        selector: selector,
        block: erasedBlock,
        addSubclassOverride: addSubclassOverrideWithObjectIfNeeded,
        swizzleOriginalMethod: swizzleOriginalMethodWithObject
      )
    }

    ChouTi.assertFailure("intercept only supports void methods with one arg of supported types", metadata: [
      "selector": NSStringFromSelector(selector),
      "argType": String(describing: Arg.self),
    ])
    return SimpleCancellableToken(cancel: { _ in })
  }

  /// Intercepts a void, single-argument instance method on the given object.
  private static func interceptSingleArg(
    _ object: AnyObject,
    selector: Selector,
    block: @escaping InstanceMethodInvokeBlockWithArgAny,
    addSubclassOverride: (_ subclass: AnyClass, _ originalClass: AnyClass, _ selector: Selector) -> Void,
    swizzleOriginalMethod: (_ originalClass: AnyClass, _ selector: Selector) -> Void
  ) -> CancellableToken {
    guard let currentClass: AnyClass = object_getClass(object) else {
      ChouTi.assertFailure("Failed to get current class") // impossible as object is not nil
      return SimpleCancellableToken(cancel: { _ in })
    }

    let currentClassName = NSStringFromClass(currentClass)
    let isKVOClass = currentClassName.hasPrefix("NSKVONotifying_")

    let state = state(for: object)

    let originalClass: AnyClass
    if let storedOriginalClass = state.originalClass {
      originalClass = storedOriginalClass
    } else if isKVOClass, let superClass = class_getSuperclass(currentClass) {
      // KVO class, use the superclass as the original class.
      let resolvedOriginalClass: AnyClass = resolveOriginalClass(from: superClass)
      originalClass = resolvedOriginalClass
      state.originalClass = resolvedOriginalClass
    } else {
      let resolvedOriginalClass: AnyClass = resolveOriginalClass(from: currentClass)
      originalClass = resolvedOriginalClass
      state.originalClass = resolvedOriginalClass
    }

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to find method for selector", metadata: [
        "selector": NSStringFromSelector(selector),
        "class": NSStringFromClass(originalClass),
      ])
      return SimpleCancellableToken(cancel: { _ in })
    }

    guard isVoidSingleArgMethod(originalMethod) else {
      ChouTi.assertFailure("intercept only supports void methods with one arg", metadata: [
        "selector": NSStringFromSelector(selector),
        "class": NSStringFromClass(originalClass),
      ])
      return SimpleCancellableToken(cancel: { _ in })
    }

    guard state.hookBlocksBySelector[selector] == nil else {
      ChouTi.assertFailure("intercept only supports one signature per selector; existing no-arg hook found", metadata: [
        "selector": NSStringFromSelector(selector),
        "class": NSStringFromClass(originalClass),
      ])
      return SimpleCancellableToken(cancel: { _ in })
    }

    let token = ValueCancellableToken(value: block) { [weak object] token in
      guard let object else {
        return
      }
      removeHookWithArg(from: object, selector: selector, token: token)
    }

    var hooks = state.hookBlocksBySelectorWithArg[selector] ?? HookBlocksWithArg()
    let needsSwizzle = hooks.isEmpty
    token.store(in: &hooks)
    state.hookBlocksBySelectorWithArg[selector] = hooks

    guard needsSwizzle else {
      return token
    }

    if isKVOClass {
      // KVO already isa-swizzled this instance, patch the original method instead.
      swizzleOriginalMethod(originalClass, selector)
      state.kvoSwizzledSelectors.insert(selector)

      if state.kvoDeallocationTokens[selector] == nil {
        let token = (object as? NSObject)?.onDeallocate {
          decrementKVOCallbackCount(for: originalClass, selector: selector)
        }
        if let token {
          state.kvoDeallocationTokens[selector] = token
        }
      }

      incrementKVOCallbackCount(for: originalClass, selector: selector)
    } else {
      // Non-KVO class, isa-swizzle to a dynamic subclass.
      let subclass: AnyClass = ensureSubclass(for: originalClass)
      object_setClass(object, subclass)
      addSubclassOverride(subclass, originalClass, selector)
    }

    return token
  }

  /// Removes a previously registered single-argument hook and cleans up swizzling if it's the last hook.
  private static func removeHookWithArg(from object: AnyObject, selector: Selector, token: ValueCancellableToken<InstanceMethodInvokeBlockWithArgAny>) {
    let state = state(for: object)
    guard var hooks = state.hookBlocksBySelectorWithArg[selector] else {
      return
    }

    token.remove(from: &hooks)

    if hooks.isEmpty {
      state.hookBlocksBySelectorWithArg.removeValue(forKey: selector)

      if let originalClass = state.originalClass, state.kvoSwizzledSelectors.contains(selector) {
        decrementKVOCallbackCount(for: originalClass, selector: selector)
        state.kvoSwizzledSelectors.remove(selector)
      }

      if let deallocToken = state.kvoDeallocationTokens[selector] {
        deallocToken.cancel()
        state.kvoDeallocationTokens.removeValue(forKey: selector)
      }
    } else {
      state.hookBlocksBySelectorWithArg[selector] = hooks
    }

    guard state.hookBlocksBySelector.isEmpty, state.hookBlocksBySelectorWithArg.isEmpty else {
      return
    }

    revertToOriginalClassIfNeeded(object: object, originalClass: state.originalClass)
    state.originalClass = nil
  }

  /// Invokes all hooks for a selector with a single argument in registration order and ensures the original is called at most once.
  private static func invokeHooksWithAnyArg(
    on object: AnyObject,
    selector: Selector,
    arg: Any,
    callOriginal: @escaping (Any) -> Void
  ) {
    guard let state = objc_getAssociatedObject(object, &AssociateKey.state) as? State else {
      callOriginal(arg)
      return
    }

    let shouldInvokeHooks = enterReentrancyGuard(state: state, selector: selector)
    defer {
      exitReentrancyGuard(state: state, selector: selector)
    }

    if shouldInvokeHooks == false {
      callOriginal(arg)
      return
    }

    var didCallOriginal = false
    let callOriginalOnce: (Any) -> Void = { value in
      guard didCallOriginal == false else {
        return
      }
      didCallOriginal = true
      callOriginal(value)
    }

    guard let hooks = state.hookBlocksBySelectorWithArg[selector], hooks.isEmpty == false else {
      callOriginalOnce(arg)
      return
    }

    for token in hooks.values {
      token.value(object, selector, arg, callOriginalOnce)
    }
  }

  private static func addSubclassOverrideWithIntIfNeeded(
    subclass: AnyClass,
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = "\(NSStringFromClass(subclass))|\(NSStringFromSelector(selector))"

    subclassSelectorOverridesLock.lock()
    if subclassSelectorOverrides.contains(key) {
      subclassSelectorOverridesLock.unlock()
      return
    }
    subclassSelectorOverrides.insert(key)
    subclassSelectorOverridesLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get original method for subclass override") // impossible
      return
    }

    let originalImplementation = unsafeBitCast(
      class_getMethodImplementation(originalClass, selector),
      to: VoidMethodWithIntIMP.self
    )

    let newImplementation: @convention(block) (AnyObject, Int) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        guard let typedValue = value as? Int else {
          ChouTi.assertFailure("intercept arg type mismatch", metadata: [
            "selector": NSStringFromSelector(selector),
            "expected": String(describing: Int.self),
            "actual": String(describing: type(of: value)),
          ])
          return
        }
        originalImplementation(object, selector, typedValue)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let methodTypeEncoding = method_getTypeEncoding(originalMethod)
    let newIMP = imp_implementationWithBlock(newImplementation)
    class_addMethod(subclass, selector, newIMP, methodTypeEncoding)
    subclassMethodIMPs.append(newIMP)
  }

  private static func addSubclassOverrideWithCGSizeIfNeeded(
    subclass: AnyClass,
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = "\(NSStringFromClass(subclass))|\(NSStringFromSelector(selector))"

    subclassSelectorOverridesLock.lock()
    if subclassSelectorOverrides.contains(key) {
      subclassSelectorOverridesLock.unlock()
      return
    }
    subclassSelectorOverrides.insert(key)
    subclassSelectorOverridesLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get original method for subclass override") // impossible
      return
    }

    let originalImplementation = unsafeBitCast(
      class_getMethodImplementation(originalClass, selector),
      to: VoidMethodWithCGSizeIMP.self
    )

    let newImplementation: @convention(block) (AnyObject, CGSize) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        guard let typedValue = value as? CGSize else {
          ChouTi.assertFailure("intercept arg type mismatch", metadata: [
            "selector": NSStringFromSelector(selector),
            "expected": String(describing: CGSize.self),
            "actual": String(describing: type(of: value)),
          ])
          return
        }
        originalImplementation(object, selector, typedValue)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let methodTypeEncoding = method_getTypeEncoding(originalMethod)
    let newIMP = imp_implementationWithBlock(newImplementation)
    class_addMethod(subclass, selector, newIMP, methodTypeEncoding)
    subclassMethodIMPs.append(newIMP)
  }

  private static func addSubclassOverrideWithCGRectIfNeeded(
    subclass: AnyClass,
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = "\(NSStringFromClass(subclass))|\(NSStringFromSelector(selector))"

    subclassSelectorOverridesLock.lock()
    if subclassSelectorOverrides.contains(key) {
      subclassSelectorOverridesLock.unlock()
      return
    }
    subclassSelectorOverrides.insert(key)
    subclassSelectorOverridesLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get original method for subclass override") // impossible
      return
    }

    let originalImplementation = unsafeBitCast(
      class_getMethodImplementation(originalClass, selector),
      to: VoidMethodWithCGRectIMP.self
    )

    let newImplementation: @convention(block) (AnyObject, CGRect) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        guard let typedValue = value as? CGRect else {
          ChouTi.assertFailure("intercept arg type mismatch", metadata: [
            "selector": NSStringFromSelector(selector),
            "expected": String(describing: CGRect.self),
            "actual": String(describing: type(of: value)),
          ])
          return
        }
        originalImplementation(object, selector, typedValue)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let methodTypeEncoding = method_getTypeEncoding(originalMethod)
    let newIMP = imp_implementationWithBlock(newImplementation)
    class_addMethod(subclass, selector, newIMP, methodTypeEncoding)
    subclassMethodIMPs.append(newIMP)
  }

  private static func addSubclassOverrideWithObjectIfNeeded(
    subclass: AnyClass,
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = "\(NSStringFromClass(subclass))|\(NSStringFromSelector(selector))"

    subclassSelectorOverridesLock.lock()
    if subclassSelectorOverrides.contains(key) {
      subclassSelectorOverridesLock.unlock()
      return
    }
    subclassSelectorOverrides.insert(key)
    subclassSelectorOverridesLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get original method for subclass override") // impossible
      return
    }

    let originalImplementation = unsafeBitCast(
      class_getMethodImplementation(originalClass, selector),
      to: VoidMethodWithObjectIMP.self
    )

    let newImplementation: @convention(block) (AnyObject, AnyObject) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        originalImplementation(object, selector, value as AnyObject)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let methodTypeEncoding = method_getTypeEncoding(originalMethod)
    let newIMP = imp_implementationWithBlock(newImplementation)
    class_addMethod(subclass, selector, newIMP, methodTypeEncoding)
    subclassMethodIMPs.append(newIMP)
  }

  /// Swizzles the original class method (single argument) when KVO has already swizzled the instance.
  private static func swizzleOriginalMethodWithInt(
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = methodKey(originalClass: originalClass, selector: selector)

    swizzledMethodsLock.lock()
    if swizzledMethods.contains(key) {
      swizzledMethodsLock.unlock()
      return
    }
    swizzledMethods.insert(key)
    swizzledMethodsLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get method for original class swizzling") // impossible
      return
    }

    let originalIMP = method_getImplementation(originalMethod)
    let originalImplementation = unsafeBitCast(originalIMP, to: VoidMethodWithIntIMP.self)

    let newImplementation: @convention(block) (AnyObject, Int) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        guard let typedValue = value as? Int else {
          ChouTi.assertFailure("intercept arg type mismatch", metadata: [
            "selector": NSStringFromSelector(selector),
            "expected": String(describing: Int.self),
            "actual": String(describing: type(of: value)),
          ])
          return
        }
        originalImplementation(object, selector, typedValue)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let newIMP = imp_implementationWithBlock(newImplementation)
    method_setImplementation(originalMethod, newIMP)

    swizzledMethodOriginalIMPsLock.lock()
    swizzledMethodOriginalIMPs[key] = originalIMP
    swizzledMethodOriginalIMPsLock.unlock()

    swizzledMethodIMPsLock.lock()
    swizzledMethodIMPs[key] = newIMP
    swizzledMethodIMPsLock.unlock()
  }

  private static func swizzleOriginalMethodWithCGSize(
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = methodKey(originalClass: originalClass, selector: selector)

    swizzledMethodsLock.lock()
    if swizzledMethods.contains(key) {
      swizzledMethodsLock.unlock()
      return
    }
    swizzledMethods.insert(key)
    swizzledMethodsLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get method for original class swizzling") // impossible
      return
    }

    let originalIMP = method_getImplementation(originalMethod)
    let originalImplementation = unsafeBitCast(originalIMP, to: VoidMethodWithCGSizeIMP.self)

    let newImplementation: @convention(block) (AnyObject, CGSize) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        guard let typedValue = value as? CGSize else {
          ChouTi.assertFailure("intercept arg type mismatch", metadata: [
            "selector": NSStringFromSelector(selector),
            "expected": String(describing: CGSize.self),
            "actual": String(describing: type(of: value)),
          ])
          return
        }
        originalImplementation(object, selector, typedValue)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let newIMP = imp_implementationWithBlock(newImplementation)
    method_setImplementation(originalMethod, newIMP)

    swizzledMethodOriginalIMPsLock.lock()
    swizzledMethodOriginalIMPs[key] = originalIMP
    swizzledMethodOriginalIMPsLock.unlock()

    swizzledMethodIMPsLock.lock()
    swizzledMethodIMPs[key] = newIMP
    swizzledMethodIMPsLock.unlock()
  }

  private static func swizzleOriginalMethodWithCGRect(
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = methodKey(originalClass: originalClass, selector: selector)

    swizzledMethodsLock.lock()
    if swizzledMethods.contains(key) {
      swizzledMethodsLock.unlock()
      return
    }
    swizzledMethods.insert(key)
    swizzledMethodsLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get method for original class swizzling") // impossible
      return
    }

    let originalIMP = method_getImplementation(originalMethod)
    let originalImplementation = unsafeBitCast(originalIMP, to: VoidMethodWithCGRectIMP.self)

    let newImplementation: @convention(block) (AnyObject, CGRect) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        guard let typedValue = value as? CGRect else {
          ChouTi.assertFailure("intercept arg type mismatch", metadata: [
            "selector": NSStringFromSelector(selector),
            "expected": String(describing: CGRect.self),
            "actual": String(describing: type(of: value)),
          ])
          return
        }
        originalImplementation(object, selector, typedValue)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let newIMP = imp_implementationWithBlock(newImplementation)
    method_setImplementation(originalMethod, newIMP)

    swizzledMethodOriginalIMPsLock.lock()
    swizzledMethodOriginalIMPs[key] = originalIMP
    swizzledMethodOriginalIMPsLock.unlock()

    swizzledMethodIMPsLock.lock()
    swizzledMethodIMPs[key] = newIMP
    swizzledMethodIMPsLock.unlock()
  }

  private static func swizzleOriginalMethodWithObject(
    originalClass: AnyClass,
    selector: Selector
  ) {
    let key = methodKey(originalClass: originalClass, selector: selector)

    swizzledMethodsLock.lock()
    if swizzledMethods.contains(key) {
      swizzledMethodsLock.unlock()
      return
    }
    swizzledMethods.insert(key)
    swizzledMethodsLock.unlock()

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get method for original class swizzling") // impossible
      return
    }

    let originalIMP = method_getImplementation(originalMethod)
    let originalImplementation = unsafeBitCast(originalIMP, to: VoidMethodWithObjectIMP.self)

    let newImplementation: @convention(block) (AnyObject, AnyObject) -> Void = { object, arg in
      let callOriginal: (Any) -> Void = { value in
        originalImplementation(object, selector, value as AnyObject)
      }
      invokeHooksWithAnyArg(on: object, selector: selector, arg: arg, callOriginal: callOriginal)
    }

    let newIMP = imp_implementationWithBlock(newImplementation)
    method_setImplementation(originalMethod, newIMP)

    swizzledMethodOriginalIMPsLock.lock()
    swizzledMethodOriginalIMPs[key] = originalIMP
    swizzledMethodOriginalIMPsLock.unlock()

    swizzledMethodIMPsLock.lock()
    swizzledMethodIMPs[key] = newIMP
    swizzledMethodIMPsLock.unlock()
  }

  /// Validates if a method is a void, single-argument method.
  private static func isVoidSingleArgMethod(_ method: Method) -> Bool {
    guard method_getNumberOfArguments(method) == 3 else {
      return false
    }

    let returnType = method_copyReturnType(method)
    defer {
      free(returnType)
    }
    if String(cString: returnType) != "v" {
      return false
    }

    guard let selfType = method_copyArgumentType(method, 0),
          let cmdType = method_copyArgumentType(method, 1),
          let argType = method_copyArgumentType(method, 2)
    else {
      return false
    }
    defer {
      free(selfType)
      free(cmdType)
      free(argType)
    }

    return String(cString: selfType) == "@" && String(cString: cmdType) == ":"
  }
}
