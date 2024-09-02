//
//  DynamicLookup.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/11/23.
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

/// A type that you can use to query private properties.
@dynamicMemberLookup
public struct DynamicLookup {

  private let value: Any
  private let mirror: Mirror

  /// Initialize a `DynamicLookup` with a value.
  ///
  /// - Parameter value: A value to lookup properties.
  public init(_ value: Any) {
    self.value = value

    let mirror = Mirror(reflecting: value)
    switch mirror.displayStyle {
    case .optional:
      if let unwrapped = mirror.unwrapped() {
        self.mirror = unwrapped
      } else {
        self.mirror = mirror
      }
    default:
      self.mirror = mirror
    }
  }

  /// Get a property by name.
  public subscript<T>(dynamicMember member: String) -> T? {
    (property(member) as? T) ?? lazyProperty(member) as? T
  }

  /// Get all property names.
  public func propertyNames() -> [String] {
    mirror.children.compactMap(\.label)
  }

  /// Get a property by name.
  public func property<T>(_ name: String) -> T? {
    property(name) as? T
  }

  /// Get a property by name.
  public func property(_ name: String) -> Any? {
    mirror.children.first(where: { $0.label == name })?.value
  }

  /// Get a lazy property by name.
  public func lazyProperty<T>(_ name: String) -> T? {
    lazyProperty(name) as? T
  }

  /// Get a lazy property by name.
  public func lazyProperty(_ name: String) -> Any? {
    mirror.children.first(where: { $0.label == "$__lazy_storage_$_\(name)" })?.value
  }

  /**
   Get a value by key path.

   Example:
   For a type:
   ```
   class Foo {

     private let bar: Bar
   }

   class Bar {

     private lazy var someString: String = "Hello"
   }
   ```

   You can use the code below to access the private properties.
   ```
   DynamicLookup(foo).keyPath("bar.someString") as? String
   ```

   - Parameter keyPath: A key path to lookup.
   - Returns: A value.
   */
  public func keyPath<T>(_ keyPath: String) -> T? {
    self.keyPath(keyPath) as? T
  }

  /// Get a value by key path.
  ///
  /// - Parameter keyPath: A key path to lookup.
  /// - Returns: A value.
  public func keyPath(_ keyPath: String) -> Any? {
    keyPath.components(separatedBy: ".").reduce(self) { lookup, key -> DynamicLookup? in
      guard let lookup else {
        return nil
      }
      guard let next = lookup.property(key) ?? lookup.lazyProperty(key) else {
        return nil
      }
      return DynamicLookup(next)
    }?.value
  }
}

extension Mirror {

  func unwrapped() -> Mirror? {
    switch displayStyle {
    case .optional:
      if let unwrappedValue = children.first(where: { $0.label == "some" })?.value {
        return Mirror(reflecting: unwrappedValue).unwrapped()
      } else {
        return nil
      }
    default:
      return self
    }
  }
}

/// https://www.hackingwithswift.com/swift/4.2/dynamic-member-lookup
