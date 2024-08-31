//
//  BindingObservationStorageProviding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/15/23.
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
///
/// The storage has the same life cycle as the host.
///
/// ⚠️ `BindingObservationStorageProviding` provides a convenient default implementation of `bindingObservationStorage`
/// using Objective-C Runtime. However, it may cause issues if the property is accessed simultaneously.
///
/// Provide an explicit implementation whenever possible, such as:
/// ```swift
/// // MARK: - BindingObservationStorageProviding
///
/// extension YourType: BindingObservationStorageProviding {
///
///   private(set) lazy var bindingObservationStorage = BindingObservationStorage()
/// }
/// ```
public protocol BindingObservationStorageProviding: AnyObject {

  /// Provide a binding observation storage.
  ///
  /// The storage has the same life cycle as the host.
  var bindingObservationStorage: BindingObservationStorage { get }
}

private enum AssociateKey {
  static var bindingObservationStorageKey: UInt8 = 0
}

public extension BindingObservationStorageProviding {

  var bindingObservationStorage: BindingObservationStorage {
    if let storage = objc_getAssociatedObject(self, &AssociateKey.bindingObservationStorageKey) as? BindingObservationStorage {
      return storage
    }

    let storage = BindingObservationStorage()
    objc_setAssociatedObject(self, &AssociateKey.bindingObservationStorageKey, storage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return storage
  }
}

extension NSObject: BindingObservationStorageProviding {}
