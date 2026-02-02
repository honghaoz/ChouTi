//
//  InstanceMethodInterceptor.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/31/26.
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

import ObjectiveC
import Foundation

public typealias InstanceMethodInvokeBlock = (_ object: AnyObject, _ selector: Selector, _ callOriginal: @escaping () -> Void) -> Void
public typealias InstanceMethodInvokeBlockWithArg<Arg> = (_ object: AnyObject, _ selector: Selector, _ arg: Arg, _ callOriginal: @escaping (Arg) -> Void) -> Void

public extension NSObject {

  /// Intercepts a void, no-argument instance method on this object.
  ///
  /// This method could be called on the same selector multiple times, the block will be called in the order of the calls.
  ///
  /// The interceptor receives a `callOriginal` callback that invokes the original implementation. If multiple interceptors
  /// are registered for the same selector, all interceptors run regardless of whether any of them calls `callOriginal`.
  /// The original implementation is executed at most once per invocation.
  ///
  /// - Parameters:
  ///   - selector: The selector to intercept. The selector must be a void method with no arguments.
  ///   - block: The block to call when the method is invoked. The block will be called with the object, the selector, and a callback to call the original method.
  /// - Returns: A cancellable token that can be used to cancel the interception.
  @discardableResult
  func intercept(selector: Selector, block: @escaping InstanceMethodInvokeBlock) -> CancellableToken {
    InstanceMethodInterceptor.intercept(self, selector: selector, block: block)
  }

  /// Intercepts a void, single-argument instance method on this object.
  ///
  /// This method could be called on the same selector multiple times, the block will be called in the order of the calls.
  ///
  /// The interceptor receives a `callOriginal` callback that invokes the original implementation. If multiple interceptors
  /// are registered for the same selector, all interceptors run regardless of whether any of them calls `callOriginal`.
  /// The original implementation is executed at most once per invocation.
  ///
  /// - Parameters:
  ///   - selector: The selector to intercept. The selector must be a void method with a single argument.
  ///   - block: The block to call when the method is invoked. The block will be called with the object, the selector, the argument, and a callback to call the original method.
  /// - Returns: A cancellable token that can be used to cancel the interception.
  @discardableResult
  func intercept<Arg>(selector: Selector, block: @escaping InstanceMethodInvokeBlockWithArg<Arg>) -> CancellableToken {
    InstanceMethodInterceptor.intercept(self, selector: selector, block: block)
  }
}

/// The instance method interceptor.
///
/// The interceptor uses isa swizzling to intercept the method. It's important to understand how this interacts with
/// KVO (Key-Value Observing), which also uses isa-swizzling.
///
/// Ideal pattern:
/// 1. Call `intercept(_:selector:block:)` first. The class becomes: ChouTiIMI_<OriginalClass>
/// 2. Setup KVO observation later. The class becomes: NSKVONotifying_ChouTiIMI_<OriginalClass>
/// 3. Remove KVO observation later. The class becomes: ChouTiIMI_<OriginalClass>
/// 4. Cancel the interception later. The class reverts to the original class: <OriginalClass>
///
/// Other patterns are also supported, but may not be as clean.
///
/// - Pattern 1: Intercept first, then KVO:
///   1. Call `intercept(_:selector:block:)` -> class becomes: ChouTiIMI_<OriginalClass>
///   2. Setup KVO observation -> class becomes: NSKVONotifying_ChouTiIMI_<OriginalClass>
///   3. Cancel the interception -> class stays: NSKVONotifying_ChouTiIMI_<OriginalClass>
///   4. Remove KVO observation -> class becomes: ChouTiIMI_<OriginalClass> (won't revert to the original class)
///
///   This pattern ended up with a subclass of the original class. To revert to the original class, you can call
///   `intercept(_:selector:block:)` again then cancel it.
///
/// - Pattern 2: KVO first, then intercept:
///   1. Setup KVO observation -> class becomes: NSKVONotifying_<OriginalClass>
///   2. Call `intercept(_:selector:block:)` -> class stays: NSKVONotifying_<OriginalClass> (the original class's method is swizzled)
///   3. Cancel the interception -> class stays: NSKVONotifying_<OriginalClass> (the original class's method is restored)
///   4. Remove KVO observation -> class becomes: <OriginalClass>
///
///   This pattern could be ended up with a clean state. However, during the process, the original class method is modified,
///   which may break other mechanisms that also modify the same method on the original class.
enum InstanceMethodInterceptor {

  typealias InstanceMethodInvokeBlockWithArgAny = (_ object: AnyObject, _ selector: Selector, _ arg: Any, _ callOriginal: @escaping (Any) -> Void) -> Void

  typealias HookBlocks = OrderedDictionary<ObjectIdentifier, ValueCancellableToken<InstanceMethodInvokeBlock>>
  typealias HookBlocksWithArg = OrderedDictionary<ObjectIdentifier, ValueCancellableToken<InstanceMethodInvokeBlockWithArgAny>>

  private typealias VoidMethodIMP = @convention(c) (AnyObject, Selector) -> Void

  final class State {
    /// The "true" original class for this instance (before any isa-swizzle).
    var originalClass: AnyClass?
    /// Hooks registered for each selector on this instance.
    var hookBlocksBySelector: [Selector: HookBlocks] = [:]
    /// Hooks registered for each selector (single-argument) on this instance.
    var hookBlocksBySelectorWithArg: [Selector: HookBlocksWithArg] = [:]
    /// Track selectors swizzled via KVO path for cleanup.
    var kvoSwizzledSelectors: Set<Selector> = []
    /// Track deallocation tokens for KVO swizzling cleanup.
    var kvoDeallocationTokens: [Selector: CancellableToken] = [:]
  }

  enum AssociateKey {
    static var state: UInt8 = 0
  }

  private static let stateLock = NSLock()

  static func state(for object: AnyObject) -> State {
    stateLock.lock()
    defer {
      stateLock.unlock()
    }

    if let existing = objc_getAssociatedObject(object, &AssociateKey.state) as? State {
      return existing
    }

    let newState = State()
    objc_setAssociatedObject(object, &AssociateKey.state, newState, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return newState
  }

  /// Intercepts a void, no-argument instance method on the given object.
  static func intercept(_ object: AnyObject, selector: Selector, block: @escaping InstanceMethodInvokeBlock) -> CancellableToken {
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

    guard isVoidNoArgsMethod(originalMethod) else {
      ChouTi.assertFailure("intercept only supports void methods with no args", metadata: [
        "selector": NSStringFromSelector(selector),
        "class": NSStringFromClass(originalClass),
      ])
      return SimpleCancellableToken(cancel: { _ in })
    }

    guard state.hookBlocksBySelectorWithArg[selector] == nil else {
      ChouTi.assertFailure("intercept only supports one signature per selector; existing single-arg hook found", metadata: [
        "selector": NSStringFromSelector(selector),
        "class": NSStringFromClass(originalClass),
      ])
      return SimpleCancellableToken(cancel: { _ in })
    }

    let token = ValueCancellableToken(value: block) { [weak object] token in
      guard let object else {
        return
      }
      removeHook(from: object, selector: selector, token: token)
    }

    var hooks = state.hookBlocksBySelector[selector] ?? HookBlocks()
    let needsSwizzle = hooks.isEmpty
    token.store(in: &hooks)
    state.hookBlocksBySelector[selector] = hooks

    guard needsSwizzle else {
      return token
    }

    if isKVOClass {
      // KVO already isa-swizzled this instance, patch the original method instead.
      swizzleOriginalMethod(originalClass: originalClass, selector: selector)
      state.kvoSwizzledSelectors.insert(selector)

      if state.kvoDeallocationTokens[selector] == nil {
        // observe deallocation to handle deallocation before token cancellation
        //
        // it's possible that the instance may deallocate directly without cancelling the cancellable token explicitly,
        // in this case, even though the cancellable token callback is still triggered, but the self is nil, hence the
        // decrement logic will not be executed.
        // to avoid this, we observe deallocation and decrement the callback count.
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
      addSubclassOverrideIfNeeded(subclass: subclass, originalClass: originalClass, selector: selector)
    }

    return token
  }

  /// Removes a previously registered hook and cleans up swizzling if it's the last hook.
  private static func removeHook(from object: AnyObject, selector: Selector, token: ValueCancellableToken<InstanceMethodInvokeBlock>) {
    let state = state(for: object)
    guard var hooks = state.hookBlocksBySelector[selector] else {
      return
    }

    token.remove(from: &hooks)

    if hooks.isEmpty {
      state.hookBlocksBySelector.removeValue(forKey: selector)

      if let originalClass = state.originalClass, state.kvoSwizzledSelectors.contains(selector) {
        decrementKVOCallbackCount(for: originalClass, selector: selector)
        state.kvoSwizzledSelectors.remove(selector)
      }

      if let deallocToken = state.kvoDeallocationTokens[selector] {
        deallocToken.cancel()
        state.kvoDeallocationTokens.removeValue(forKey: selector)
      }
    } else {
      state.hookBlocksBySelector[selector] = hooks
    }

    guard state.hookBlocksBySelector.isEmpty, state.hookBlocksBySelectorWithArg.isEmpty else {
      return
    }

    revertToOriginalClassIfNeeded(object: object, originalClass: state.originalClass)
    state.originalClass = nil
  }

  /// Invokes all hooks for a selector in registration order and ensures the original is called at most once.
  private static func invokeHooks(on object: AnyObject, selector: Selector, callOriginal: @escaping () -> Void) {
    guard let state = objc_getAssociatedObject(object, &AssociateKey.state) as? State else {
      callOriginal()
      return
    }

    // prevent infinite recursion when a hook re‑enters the same selector on the same thread, but still allow concurrent
    // calls on different threads to run hooks.
    let shouldInvokeHooks = enterReentrancyGuard(state: state, selector: selector)
    defer {
      exitReentrancyGuard(state: state, selector: selector)
    }

    if shouldInvokeHooks == false {
      callOriginal()
      return
    }

    var didCallOriginal = false
    let callOriginalOnce = {
      guard didCallOriginal == false else {
        return
      }
      didCallOriginal = true
      callOriginal()
    }

    guard let hooks = state.hookBlocksBySelector[selector], hooks.isEmpty == false else {
      callOriginalOnce()
      return
    }

    for token in hooks.values {
      token.value(object, selector, callOriginalOnce)
    }
  }

  // MARK: - Subclassing

  private enum Constants {

    /// The prefix for the dynamic subclasses created by this interceptor.
    static let subclassPrefix = "ChouTiIMI_"
  }

  // MARK: - Reentrancy Guard

  /// Records “this thread is now inside selector X for object/state Y” and returns whether hooks should run.
  static func enterReentrancyGuard(state: State, selector: Selector) -> Bool {
    let threadDict = Thread.current.threadDictionary // per‑thread storage,
    let stateKey = NSValue(nonretainedObject: state)
    let selectorKey = NSStringFromSelector(selector) as NSString

    let selectorCounts: NSMutableDictionary
    if let existing = threadDict[stateKey] as? NSMutableDictionary {
      selectorCounts = existing
    } else {
      let newCounts = NSMutableDictionary()
      threadDict[stateKey] = newCounts
      selectorCounts = newCounts
    }

    let depth = (selectorCounts[selectorKey] as? Int) ?? 0
    selectorCounts[selectorKey] = depth + 1
    return depth == 0
  }

  /// Decrements the recursion depth for that selector on this thread, and cleans up storage when it reaches zero.
  static func exitReentrancyGuard(state: State, selector: Selector) {
    let threadDict = Thread.current.threadDictionary
    let stateKey = NSValue(nonretainedObject: state)
    guard let selectorCounts = threadDict[stateKey] as? NSMutableDictionary else {
      return
    }

    let selectorKey = NSStringFromSelector(selector) as NSString
    let depth = (selectorCounts[selectorKey] as? Int) ?? 1
    if depth <= 1 {
      selectorCounts.removeObject(forKey: selectorKey)
      if selectorCounts.count == 0 {
        threadDict.removeObject(forKey: stateKey)
      }
    } else {
      selectorCounts[selectorKey] = depth - 1
    }
  }

  /// Resolves the original class if the given class is one of our dynamic subclasses.
  static func resolveOriginalClass(from aClass: AnyClass) -> AnyClass {
    let className = NSStringFromClass(aClass)
    guard className.hasPrefix(Constants.subclassPrefix),
          let superClass = class_getSuperclass(aClass)
    else {
      return aClass
    }
    return superClass
  }

  private static func subclassName(for originalClass: AnyClass) -> String {
    let originalClassName = NSStringFromClass(originalClass)
    if originalClassName.hasPrefix(Constants.subclassPrefix) {
      return originalClassName
    }
    return "\(Constants.subclassPrefix)\(originalClassName)"
  }

  /// Ensures a dynamic subclass exists and returns it.
  static func ensureSubclass(for originalClass: AnyClass) -> AnyClass {
    let subclassName = subclassName(for: originalClass)
    if let existingClass = NSClassFromString(subclassName) {
      return existingClass
    }

    guard let subclass = objc_allocateClassPair(originalClass, subclassName, 0) else {
      ChouTi.assertFailure("Failed to create subclass for isa swizzling") // impossible as subclass name is derived from original class name, which is guaranteed to be valid.
      return originalClass
    }

    objc_registerClassPair(subclass)
    return subclass
  }

  /// Tracks which subclass/selector pairs have been overridden.
  static var subclassSelectorOverrides: Set<String> = []
  static let subclassSelectorOverridesLock = NSLock()

  /// Keeps IMPs alive for dynamically added subclass methods.
  static var subclassMethodIMPs: [IMP] = []

  private static func addSubclassOverrideIfNeeded(subclass: AnyClass, originalClass: AnyClass, selector: Selector) {
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
      to: VoidMethodIMP.self
    )

    let newImplementation: @convention(block) (AnyObject) -> Void = { object in
      let callOriginal = {
        originalImplementation(object, selector)
      }
      invokeHooks(on: object, selector: selector, callOriginal: callOriginal)
    }

    let methodTypeEncoding = method_getTypeEncoding(originalMethod)
    let newIMP = imp_implementationWithBlock(newImplementation)
    class_addMethod(subclass, selector, newIMP, methodTypeEncoding)
    subclassMethodIMPs.append(newIMP)
  }

  /// Restores the original class if this instance is currently using our dynamic subclass.
  static func revertToOriginalClassIfNeeded(object: AnyObject, originalClass: AnyClass?) {
    guard let originalClass else {
      return // impossible
    }

    guard let currentClass = object_getClass(object) else {
      return // impossible
    }

    // safety check: only revert if the current class is our swizzled class
    let subclassName = subclassName(for: originalClass)
    guard NSStringFromClass(currentClass) == subclassName else {
      // The class has been changed (likely by KVO)
      // We should NOT revert to the original class as it would break KVO
      return
    }

    object_setClass(object, originalClass)
  }

  // MARK: - KVO Class Swizzling

  /// KVO class swizzling is a special case where the original class method is swizzled.
  ///
  /// KVO already uses isa-swizzling to add a dynamic subclass to the instance. It's not safe to:
  /// 1. Create a dynamic subclass on top of the KVO dynamic subclass as removing KVO observation will break our class hierarchy.
  /// 2. Swizzle the KVO dynamic subclass method as removing KVO observation will remove the subclass definition.
  ///
  /// Instead, we swizzle the original class method directly, the change will be shared by all instances (KVO or non-KVO).
  /// We use reference counting to track how many instances are using each original class/selector pair.
  /// When the reference count reaches zero, we restore the original method.

  /// Stores swizzled IMPs to keep them alive for KVO-class method replacement.
  static var swizzledMethodIMPs: [String: IMP] = [:]
  static let swizzledMethodIMPsLock = NSLock()

  /// Stores original IMPs for restoration.
  static var swizzledMethodOriginalIMPs: [String: IMP] = [:]
  static let swizzledMethodOriginalIMPsLock = NSLock()

  /// Tracks which original class/selector pairs are currently swizzled.
  static var swizzledMethods: Set<String> = []
  static let swizzledMethodsLock = NSLock()

  /// Tracks how many KVO instances are using each original class/selector pair.
  static var kvoInstanceCallbackCounts: [String: Int] = [:]
  static let kvoInstanceCallbackCountsLock = NSLock()

  /// Combines class + selector into a stable dictionary key.
  static func methodKey(originalClass: AnyClass, selector: Selector) -> String {
    "\(NSStringFromClass(originalClass))|\(NSStringFromSelector(selector))"
  }

  /// Swizzles the original class method when KVO has already swizzled the instance.
  private static func swizzleOriginalMethod(originalClass: AnyClass, selector: Selector) {
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
    let originalImplementation = unsafeBitCast(originalIMP, to: VoidMethodIMP.self)

    let newImplementation: @convention(block) (AnyObject) -> Void = { object in
      let callOriginal = {
        originalImplementation(object, selector)
      }
      invokeHooks(on: object, selector: selector, callOriginal: callOriginal)
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

  /// Increment KVO usage count for an original class/selector pair.
  static func incrementKVOCallbackCount(for originalClass: AnyClass, selector: Selector) {
    let key = methodKey(originalClass: originalClass, selector: selector)
    kvoInstanceCallbackCountsLock.lock()
    kvoInstanceCallbackCounts[key, default: 0] += 1
    kvoInstanceCallbackCountsLock.unlock()
  }

  /// Decrement KVO usage count and restore the original method when it reaches zero.
  static func decrementKVOCallbackCount(for originalClass: AnyClass, selector: Selector) {
    let key = methodKey(originalClass: originalClass, selector: selector)

    kvoInstanceCallbackCountsLock.lock()
    let count = kvoInstanceCallbackCounts[key, default: 0] - 1
    if count <= 0 {
      kvoInstanceCallbackCounts.removeValue(forKey: key)
    } else {
      kvoInstanceCallbackCounts[key] = count
    }
    kvoInstanceCallbackCountsLock.unlock()

    guard count <= 0 else {
      return
    }

    guard let originalMethod = class_getInstanceMethod(originalClass, selector) else {
      ChouTi.assertFailure("Failed to get method for restoration") // impossible
      return
    }

    swizzledMethodOriginalIMPsLock.lock()
    let originalIMP = swizzledMethodOriginalIMPs[key]
    swizzledMethodOriginalIMPsLock.unlock()

    if let originalIMP {
      method_setImplementation(originalMethod, originalIMP)
    } else {
      ChouTi.assertFailure("Failed to find original IMP for restoration") // impossible
    }

    swizzledMethodsLock.lock()
    swizzledMethods.remove(key)
    swizzledMethodsLock.unlock()

    swizzledMethodIMPsLock.lock()
    swizzledMethodIMPs.removeValue(forKey: key)
    swizzledMethodIMPsLock.unlock()

    swizzledMethodOriginalIMPsLock.lock()
    swizzledMethodOriginalIMPs.removeValue(forKey: key)
    swizzledMethodOriginalIMPsLock.unlock()
  }

  // MARK: - Method Signature Validation

  /// Validates if a method is a void, no-argument method.
  private static func isVoidNoArgsMethod(_ method: Method) -> Bool {
    guard method_getNumberOfArguments(method) == 2 else {
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
          let cmdType = method_copyArgumentType(method, 1)
    else {
      return false // `method_copyArgumentType` should never return nil for valid Obj-C methods.
    }
    defer {
      free(selfType)
      free(cmdType)
    }

    return String(cString: selfType) == "@" && String(cString: cmdType) == ":"
  }
}
