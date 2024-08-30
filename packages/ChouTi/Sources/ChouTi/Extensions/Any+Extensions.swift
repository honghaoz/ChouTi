//
//  Any+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/4/24.
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
