//
//  NSObject+Swizzle_Void_to_Void.swift
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

import Foundation

public extension NSObject {

  /// Inject a callback block to the selector with a signature of `(Self) -> Void`.
  ///
  /// The first injected block will be called first.
  ///
  /// Example:
  /// ```
  /// // inject a block to the `layoutSubviews` method
  /// let token = view.inject(selector: #selector(UIView.layoutSubviews), block: { view in
  ///   // add your logic here
  /// })
  ///
  /// // cancel the injection
  /// token.cancel()
  /// ```
  ///
  /// - Parameters:
  ///   - selector: The selector to inject the callback to. The selector should match the signature of the block.
  ///   - block: The block to inject, passed in the object itself.
  /// - Returns: A cancellable token that can be used to remove the block. Return `nil` if the injection fails.
  @discardableResult
  func inject(selector: Selector, block: @escaping (Self) -> Void) -> CancellableToken? {
    // 0) prepare original class and the method to override
    guard let originalClass = object_getClass(self),
          let originalMethod = class_getInstanceMethod(originalClass, selector),
          let originalMethodImp = class_getMethodImplementation(originalClass, selector)
    else {
      ChouTi.assertFailure("Failed to get the original class/method/implementation", metadata: [
        "self": "\(self)",
        "selector": "\(selector)",
      ])
      return nil
    }

    // 1) subclass the object if needed
    let className = className
    let subclassNameKey = "\(rawPointer())_\(selector)"

    if !className.components(separatedBy: Constants.delimiter).contains(subclassNameKey) {
      // not already subclassed, needs to create a new subclass
      let subclassName = className + Constants.delimiter + subclassNameKey
      guard let subclass = objc_allocateClassPair(originalClass, subclassName, 0) else {
        ChouTi.assertFailure("Failed to create the subclass", metadata: [
          "self": "\(self)",
          "selector": "\(selector)",
          "subclassName": "\(subclassName)",
        ])
        return nil
      }

      typealias OriginalMethodIMP = @convention(c) (NSObject, Selector) -> Void
      let castedOriginalMethodImp = unsafeBitCast(originalMethodImp, to: OriginalMethodIMP.self)

      let overrideBlock: @convention(block) (NSObject) -> Void = { [weak self] object in
        ChouTi.assert(self === object, "self should be the same as the object")

        // call original method
        castedOriginalMethodImp(object, selector)

        // call injected blocks
        if let self = self {
          for (_, block) in self.blocks {
            block(object)
          }
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
        ChouTi.assertFailure("unexpected failure to add method")
        method_setImplementation(originalMethod, overrideMethodImp)
      }

      objc_registerClassPair(subclass)
      object_setClass(self, subclass)

      // dispose the subclass on deallocation
      onDeallocate {
        objc_disposeClassPair(subclass)
      }
    }

    // 2) set the blocks
    let token = TheCancellableToken { [weak self] token in
      self?.blocks.removeValue(forKey: ObjectIdentifier(token))
    }

    self.blocks[ObjectIdentifier(token)] = { object in
      if let typedSelf = object as? Self {
        block(typedSelf)
      } else {
        ChouTi.assertFailure("Type mismatch: expected \(Self.self) but got \(type(of: object))")
      }
    }

    return token
  }
}

// MARK: - Constants

private enum Constants {
  static let delimiter = "_chouti_"
}

// MARK: - NSObject + Blocks

private enum AssociateKey {
  static var blocks: UInt8 = 0
}

private extension NSObject {

  /// The blocks to be called when the selector is called.
  var blocks: OrderedDictionary<ObjectIdentifier, (NSObject) -> Void> {
    get {
      objc_getAssociatedObject(self, &AssociateKey.blocks) as? OrderedDictionary<ObjectIdentifier, (NSObject) -> Void> ?? {
        let blocks = OrderedDictionary<ObjectIdentifier, (NSObject) -> Void>()
        objc_setAssociatedObject(self, &AssociateKey.blocks, blocks, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return blocks
      }()
    }
    set {
      objc_setAssociatedObject(self, &AssociateKey.blocks, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

// MARK: - TheCancellableToken

/// A `CancellableToken` implementation that doesn't call cancel block on deinit.
private final class TheCancellableToken: CancellableToken {

  private let cancelBlock: (TheCancellableToken) -> Void

  init(cancel: @escaping (TheCancellableToken) -> Void) {
    self.cancelBlock = cancel
  }

  func cancel() {
    cancelBlock(self)
  }
}
