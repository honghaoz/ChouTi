//
//  Continuation.swift
//
//  Created by Honghao Zhang on 7/10/22.
//  Copyright © 2024 ChouTi. All rights reserved.
//

/// Aggregated continuation. It uses `CheckedContinuation` for DEBUG build, uses `UnsafeContinuation` for RELEASE build.
public struct Continuation<T, E>: Sendable where E: Error {

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
