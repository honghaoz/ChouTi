//
//  ObjectIdentifier.swift
//  ChouTi
//
//  Created by Honghao Zhang on 12/12/20.
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
