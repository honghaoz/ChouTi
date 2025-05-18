//
//  NSObject+Swizzle_Void_to_Some.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/4/23.
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

#if DEBUG

/// A code snippet to show how to override a method with a signature of `(Self) -> Int`.
///
/// Due to the limitation of Swift type system, we cannot implement this helper in a generic way.

import Foundation

extension NSObject {

  /// Override a method with a signature of `(Self) -> Int`.
  ///
  /// Example:
  /// ```
  /// layer.override(selector: #selector(CALayer.needsDisplay), block: { layer, invokeSuperMethod in
  ///   let superValue = invokeSuperMethod()
  ///   return superValue + 1
  /// })
  /// ```
  ///
  /// - Parameters:
  ///   - selector: The selector of the method to override.
  ///   - block: The block to override the original method, passed in self and the super method.
  func override(selector: Selector, block: @escaping (_ object: Self, _ invokeSuperMethod: () -> Int) -> Int) {
    // 0) prepare original class and the method to override
    guard let originalClass = object_getClass(self),
          let originalMethod = class_getInstanceMethod(originalClass, selector),
          let originalMethodImp = class_getMethodImplementation(originalClass, selector)
    else {
      ChouTi.assertFailure("Failed to get the original class/method/implementation", metadata: [
        "self": "\(self)",
        "selector": "\(selector)",
      ])
      return
    }

    // 1) make a subclass
    let subclassName = getClassName(self) + "_chouti_\(rawPointer())_\(selector)"
    guard let subclass = objc_allocateClassPair(originalClass, subclassName, 0) ?? objc_getClass(subclassName) as? AnyClass else {
      ChouTi.assertFailure("Failed to create or get the subclass", metadata: [
        "self": "\(self)",
        "selector": "\(selector)",
        "subclassName": "\(subclassName)",
      ])
      return
    }

    typealias OriginalMethodIMP = @convention(c) (NSObject, Selector) -> Int
    let castedOriginalMethodImp = unsafeBitCast(originalMethodImp, to: OriginalMethodIMP.self)

    let overrideBlock: @convention(block) (NSObject) -> Int = { object in
      if let typedSelf = object as? Self {
        return block(typedSelf) { castedOriginalMethodImp(object, selector) }
      } else {
        ChouTi.assertFailure("Type mismatch: expected \(Self.self) but got \(type(of: object))")
        return castedOriginalMethodImp(object, selector)
      }
    }

    let overrideMethodImp = imp_implementationWithBlock(overrideBlock)

    // like `override func layout() { ... }`
    let isAdded = class_addMethod(
      subclass,
      selector,
      overrideMethodImp,
      method_getTypeEncoding(originalMethod)
    )
    if !isAdded {
      method_setImplementation(originalMethod, overrideMethodImp)
    }

    // 2) set the subclass
    objc_registerClassPair(subclass)
    object_setClass(self, subclass)

    // 3) dispose the subclass on deallocation
    onDeallocate {
      objc_disposeClassPair(subclass)
    }
  }
}

#endif
