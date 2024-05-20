//
//  Type.swift
//
//  Created by Honghao Zhang on 5/15/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

// MARK: - Get type name.

/// Get type name for a value.
/// - Parameter value: A value.
/// - Returns: Type name.
@inlinable
@inline(__always)
public func typeName<T>(_ value: T) -> String {
  String(describing: T.self)
}

/// Get type name for a type.
/// - Parameter type: A type.
/// - Returns: Type name.
@inlinable
@inline(__always)
public func typeName(_ type: Any.Type) -> String {
  String(describing: type)
}

/// Get class name.
/// - Parameter any: An instance.
/// - Returns: Class name.
@inlinable
@inline(__always)
public func getClassName(_ any: Any?) -> String {
  String(cString: object_getClassName(any))
  // String(describing: instance)
}

// MARK: - Check type's type

/// Check if a type is `Array` type.
/// - Parameter type: A type.
/// - Returns: `true` if the type is `Array` type.
public func isArrayType(_ type: Any.Type) -> Bool {
  // From: https://stackoverflow.com/a/46362668/3164091
  typeName(type).hasPrefix("Array<")
}

/// Check if a type is `Set` type.
/// - Parameter type: A type.
/// - Returns: `true` if the type is `Set` type.
public func isSetType(_ type: Any.Type) -> Bool {
  typeName(type).hasPrefix("Set<")
}

/// Check if a type is `Dictionary` type.
/// - Parameter type: A type.
/// - Returns: `true` if the type is `Dictionary` type.
public func isDictionaryType(_ type: Any.Type) -> Bool {
  typeName(type).hasPrefix("Dictionary<")
}

/// Check if a type is `Optional` type.
///
/// Example:
/// - `isOptionalType(Int?.self)`
/// - `isOptionalType(type(of: value))`
///
/// - Parameter type: A type.
/// - Returns: `true` if the type is `Optional` type.
public func isOptionalType(_ type: Any.Type) -> Bool {
  /// https://stackoverflow.com/a/74481694/3164091
  type is ExpressibleByNilLiteral.Type
  // or
  // typeName(type).hasPrefix("Optional<")
}

/// Check if a value is a reference type.
/// - Parameter value: The value to check.
/// - Returns: `true` if the value is a reference type.
public func isReferenceType(_ value: Any) -> Bool {
  type(of: value) is AnyClass
}
