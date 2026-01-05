//
//  UniquelyIdentifiable.swift
//  ChouTi
//
//  Created by Honghao on 5/17/25.
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

/// A type that can be uniquely identified.
public protocol UniquelyIdentifiable {

  /// A unique identifier for the object.
  ///
  /// - Note: Using `ObjectIdentifier` may not work as expected since the memory address can be reused.
  /// For example, when an instance is just deallocated before the next instance is allocated, the new instance
  /// will have the same `ObjectIdentifier` as the previous instance:
  ///
  /// ```swift
  /// var object: NSObject? = NSObject()
  /// print ("object id1: \(ObjectIdentifier(object!))")
  /// object = nil
  /// object = NSObject()
  /// print ("object id2: \(ObjectIdentifier(object!))")
  ///
  /// // object id1: ObjectIdentifier(0x0000600003a643c0)
  /// // object id2: ObjectIdentifier(0x0000600003a643c0)
  /// ```
  ///
  /// A default implementation is provided that uses `UUID.uuidString` as the unique identifier.
  /// The default implementation is NOT thread-safe.
  var uniqueIdentifier: String { get }
}

private enum AssociateKey {
  static var uniqueIdentifierKey: UInt8 = 0
}

public extension UniquelyIdentifiable {

  var uniqueIdentifier: String {
    objc_getAssociatedObject(self, &AssociateKey.uniqueIdentifierKey) as? String ?? {
      let uuid = UUID().uuidString
      objc_setAssociatedObject(self, &AssociateKey.uniqueIdentifierKey, uuid, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return uuid
    }()
  }
}

extension NSObject: UniquelyIdentifiable {}
