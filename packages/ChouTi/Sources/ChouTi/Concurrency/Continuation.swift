//
//  Continuation.swift
//  ChouTi
//
//  Created by Honghao Zhang on 7/10/22.
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

/// Aggregated continuation. It uses `CheckedContinuation` for DEBUG build, uses `UnsafeContinuation` for RELEASE build.
public struct Continuation<T, E: Error>: Sendable {

  #if DEBUG
  public let continuation: CheckedContinuation<T, E>

  public init(continuation: CheckedContinuation<T, E>) {
    self.continuation = continuation
  }
  #else
  public let continuation: UnsafeContinuation<T, E>

  public init(continuation: UnsafeContinuation<T, E>) {
    self.continuation = continuation
  }
  #endif

  @inlinable
  @inline(__always)
  public func resume(returning value: T) {
    continuation.resume(returning: value)
  }

  @inlinable
  @inline(__always)
  public func resume(throwing error: E) {
    continuation.resume(throwing: error)
  }

  @inlinable
  @inline(__always)
  public func resume(with result: Result<T, some Error>) where E == Error {
    continuation.resume(with: result)
  }

  @inlinable
  @inline(__always)
  public func resume(with result: Result<T, E>) {
    continuation.resume(with: result)
  }

  @inlinable
  @inline(__always)
  public func resume() where T == () {
    continuation.resume()
  }
}

@inlinable
@inline(__always)
public func withContinuation<T>(function: String = #function, _ body: (Continuation<T, Never>) -> Void) async -> T {
  #if DEBUG
  await withCheckedContinuation(function: function) { (checkedContinuation: CheckedContinuation<T, Never>) in
    body(Continuation(continuation: checkedContinuation))
  }
  #else
  await withUnsafeContinuation { (unsafeContinuation: UnsafeContinuation<T, Never>) in
    body(Continuation(continuation: unsafeContinuation))
  }
  #endif
}

@inlinable
@inline(__always)
public func withThrowingContinuation<T>(function: String = #function, _ body: (Continuation<T, Error>) -> Void) async throws -> T {
  #if DEBUG
  try await withCheckedThrowingContinuation(function: function) { (checkedContinuation: CheckedContinuation<T, Error>) in
    body(Continuation(continuation: checkedContinuation))
  }
  #else
  try await withUnsafeThrowingContinuation { (unsafeContinuation: UnsafeContinuation<T, Error>) in
    body(Continuation(continuation: unsafeContinuation))
  }
  #endif
}

// public func withContinuation<T>(function: String = #function, _ fn: (CheckedContinuation<T, Never>) -> Void) async -> T {
//   #if DEBUG
//   await withCheckedContinuation(function: function, fn)
//   #else
//   await withUnsafeContinuation({ unsafeContinuation in
//     fn(CheckedContinuation(continuation: unsafeContinuation, function: function))
//   })
//   #endif
// }
//
// public func withThrowingContinuation<T>(function: String = #function, _ fn: (CheckedContinuation<T, Error>) -> Void) async throws -> T {
//   #if DEBUG
//   try await withCheckedThrowingContinuation(function: function, fn)
//   #else
//   try await withUnsafeThrowingContinuation({ unsafeContinuation in
//     fn(CheckedContinuation(continuation: unsafeContinuation, function: function))
//   })
//   #endif
// }
//
