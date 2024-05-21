//
//  Any+Extensions.swift
//
//  Created by Honghao Zhang on 1/4/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// Try to hash a value into a hasher.
///
/// Example:
/// ```
/// ChouTi.hash(value, into: &hasher)
/// ```
///
/// ```
/// var hasher = Hasher()
/// ChouTi.hash(value, into: &hasher)
/// let hashValue = hasher.finalize()
/// ```
///
/// ```
/// do {
///   try ChouTi.hash(value, into: &hasher)
/// } catch {
///   if case HashAnyError.unhashable(let value) = error {
///     print("⚠️ Can't hash value: \(value)")
///   }
/// }
/// ```
///
/// - Parameters:
///   - value: The value to hash.
///   - hasher: The hasher.
/// - Throws: Throws `HashAnyError.unhashable(_:)` if the value can't hash.
public func hash(_ value: Any?, into hasher: inout Hasher) throws {
  guard let value else {
    return
  }

  if let hashableValue = value as? any Hashable {
    hasher.combine(hashableValue)
  } else if isReferenceType(value) {
    hasher.combine(ObjectIdentifier(value as AnyObject))
  } else {
    throw HashAnyError.unhashable(value)
  }
}

/// Try to get a hashValue for Any.
///
/// Example:
/// ```
/// do {
///   let hashValue = try ChouTi.hashValue(value)
/// } catch {
///   if case HashAnyError.unhashable(let value) = error {
///     print("⚠️ Can't hash value: \(value)")
///   }
/// }
/// ```
///
/// - Parameter value: The value to get a hash value from.
/// - Throws: Throws `HashAnyError.unhashable(_:)` if the value can't hash.
/// - Returns: A hash value.
public func hashValue(_ value: Any?) throws -> Int {
  var hasher = Hasher()
  try hash(value, into: &hasher)
  return hasher.finalize()
}

/// The error from hashing a `Any` value.
public enum HashAnyError: Swift.Error {
  /// The value can't be hashed
  case unhashable(_ value: Any)
}
