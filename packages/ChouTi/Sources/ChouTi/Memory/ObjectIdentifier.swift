//
//  ObjectIdentifier.swift
//
//  Created by Honghao Zhang on 12/12/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// Get the object's raw pointer.
/// - Parameter object: An object.
/// - Returns Raw pointer.
@inlinable
@inline(__always)
public func rawPointer(_ object: AnyObject) -> UnsafeMutableRawPointer {
  // From: https://stackoverflow.com/a/48094758/3164091
  Unmanaged.passUnretained(object).toOpaque()
}

/// Get a pointer's memory address as `Int`.
///
/// This is useful to print `struct` memory address.
///
/// - Parameter object: A pointer.
/// - Returns: Memory address.
@inlinable
@inline(__always)
public func memoryAddress(_ object: UnsafeRawPointer) -> Int {
  Int(bitPattern: object)
}

public extension NSObject {

  /// Get the object's unique identifier.
  /// - Returns:
  @inlinable
  @inline(__always)
  func objectIdentifier() -> ObjectIdentifier {
    ObjectIdentifier(self)
  }

  /// Get the object's memory address.
  /// - Returns: Memory address.
  @inlinable
  @inline(__always)
  func rawPointer() -> UnsafeMutableRawPointer {
    Unmanaged.passUnretained(self).toOpaque()
  }
}

/// Performance note:
/// - Converting memory address to `String` is slow.
/// - `ObjectIdentifier(object)` is same speed as `Unmanaged.passUnretained(object).toOpaque()`
