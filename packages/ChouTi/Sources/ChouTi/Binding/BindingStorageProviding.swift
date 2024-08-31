//
//  BindingStorageProviding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/17/23.
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

/// A type that can provide a binding storage.
public protocol BindingStorageProviding {

  /// Provide a binding storage.
  ///
  /// The storage has the same life cycle as the host.
  ///
  /// ⚠️ `BindingStorageProviding` provides a convenient default implementation of `bindingStorage`
  /// using Objective-C Runtime. However, it may cause issues if the property is accessed simultaneously.
  ///
  /// Provide an explicit implementation whenever possible, such as:
  /// ```
  ///
  /// // MARK: - BindingStorageProviding
  ///
  /// let bindingStorage = BindingStorage()
  /// ```
  var bindingStorage: BindingStorage { get }
}

private enum AssociateKey {
  static var bindingStorageKey: UInt8 = 0
}

public extension BindingStorageProviding {

  var bindingStorage: BindingStorage {
    if let storage = objc_getAssociatedObject(self, &AssociateKey.bindingStorageKey) as? BindingStorage {
      return storage
    }

    let storage = BindingStorage()
    objc_setAssociatedObject(self, &AssociateKey.bindingStorageKey, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return storage
  }
}

extension NSObject: BindingStorageProviding {}
