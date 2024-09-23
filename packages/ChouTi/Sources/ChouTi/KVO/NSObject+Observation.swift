//
//  NSObject+Observation.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/18/21.
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

public extension NSObjectProtocol {

  /// Observe for a property change with a keyPath.
  ///
  /// Example:
  /// ```swift
  /// // keep a strong reference to the observer
  /// private var observer: KVOObserverType?
  ///
  /// // set up the observer
  /// observer = object.observe("status") { (object, old: Int, new: Int) in
  ///   print("object status: \(old) -> \(new)")
  /// })
  ///
  /// // stop the observer when needed, such as in deinit:
  /// observer.stop()
  /// ```
  ///
  /// - Parameters:
  ///   - keyPath: The keyPath to observe.
  ///   - handler: The callback handler.
  /// - Returns: An observer object. You are responsible for maintaining a strong reference to it to keep the observation alive.
  func observe<T>(_ keyPath: String, withHandler handler: @escaping (_ object: Self, _ old: T, _ new: T) -> Void) -> KVOObserver<Self, T> {
    KVOObserver(object: self, keyPath: keyPath, handler: handler)
  }

  /// Observe for a property change with a keyPath.
  ///
  /// This method is used for observing `RawRepresentable` such as enum types.
  ///
  /// Example:
  /// ```swift
  /// // keep a strong reference to the observer
  /// private var enumObserver: KVOObserverType? // KVOObserver<SomeObject, SomeStatus.RawValue>
  ///
  /// // set up the observer
  /// enumObserver = object.observe("status") { (object, old: SomeStatus, new: SomeStatus) in
  ///   NSLog("object status: \(old) -> \(new)")
  /// })
  ///
  /// // stop the observer when needed, such as in deinit:
  /// enumObserver.stop()
  /// ```
  ///
  /// - Parameters:
  ///   - keyPath: The keyPath to observe.
  ///   - handler: The callback handler.
  /// - Returns: An observer object. You are responsible for maintaining a strong reference to it to keep the observation alive.
  ///
  /// - Tag: NSObject.observe_RawRepresentable
  func observe<T: RawRepresentable>(_ keyPath: String, withHandler handler: @escaping (_ object: Self, _ old: T, _ new: T) -> Void) -> KVOObserver<Self, T.RawValue> {
    KVOObserver<Self, T.RawValue>(object: self, keyPath: keyPath) { object, old, new in
      guard let old = T(rawValue: old), let new = T(rawValue: new) else {
        ChouTi.assertFailure("KVOObserver: failed to convert value to \(T.self)", metadata: [
          "object": "\(object)",
          "keyPath": keyPath,
          "observerType": "\(type(of: self))",
          "old": "\(old)",
          "new": "\(new)",
        ])
        return
      }
      handler(self, old, new)
    }
  }
}
