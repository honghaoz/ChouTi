//
//  WeakBox.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/24/21.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

/// A weak box to hold an object weakly.
public final class WeakBox<T> {

  private weak var weakObject: AnyObject?

  /// The object wrapped in the box.
  ///
  /// If the object is deallocated, this value will return `nil`.
  /// You can set the object to `nil` to release the object.
  public var object: T? {
    get {
      if weakObject == nil {
        // WeakBox<AnyObject>(nil) can return Optional(<null>). check nil then return nil if needed
        return nil
      } else {
        return weakObject as? T
      }
    }
    set {
      setObject(newValue)
    }
  }

  /// Create a weak box with an object.
  /// - Parameter object: The object to be wrapped.
  public init(_ object: T?) {
    setObject(object)
  }

  private func setObject(_ object: T?) {
    guard let object else {
      weakObject = nil
      return
    }
    weakObject = object as AnyObject
  }
}

extension WeakBox: Equatable where T: Equatable {

  public static func == (lhs: WeakBox<T>, rhs: WeakBox<T>) -> Bool {
    switch (lhs.object, rhs.object) {
    case (nil, nil):
      return true
    case (.some, nil):
      return false
    case (nil, .some):
      return false
    case (let lObject, let rObject):
      return lObject == rObject
    }
  }
}

extension WeakBox: Hashable where T: Hashable {

  public func hash(into hasher: inout Hasher) {
    object?.hash(into: &hasher)
  }
}
