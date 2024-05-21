//
//  SingleReadBox.swift
//
//  Created by Honghao Zhang on 4/2/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public typealias EphemeralValue = SingleReadBox

/// A box that holds a value that can only be read once before being reset to its default.
public final class SingleReadBox<T> {

  /// The default value.
  public let defaultValue: T

  var currentValue: T?

  /// Create a box with a default value.
  /// - Parameter defaultValue: The default value.
  public init(defaultValue: T) {
    self.defaultValue = defaultValue
  }

  /// Set a value to read.
  /// - Parameter value: The value to be set.
  public func set(_ value: T) {
    currentValue = value
  }

  /// Read the value.
  ///
  /// After this reading, last set value will be reset to default.
  public func read() -> T {
    if let currentValue {
      self.currentValue = nil
      return currentValue
    } else {
      return defaultValue
    }
  }
}
