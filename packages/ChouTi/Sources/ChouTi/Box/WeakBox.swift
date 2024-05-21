//
//  WeakBox.swift
//
//  Created by Honghao Zhang on 8/24/21.
//  Copyright © 2024 ChouTi. All rights reserved.
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
