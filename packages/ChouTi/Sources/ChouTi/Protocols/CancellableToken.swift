//
//  CancellableToken.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/5/23.
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

/// A protocol that represents a cancellable operation.
public protocol CancellableToken: AnyObject, UniquelyIdentifiable {

  /// Cancels the operation.
  func cancel()
}

public extension CancellableToken {

  /// Stores this cancellable token in the specified collection.
  ///
  /// - Parameter collection: The collection in which to store this `CancellableToken`.
  @inlinable
  @inline(__always)
  func store<C>(in collection: inout C) where C: RangeReplaceableCollection, C.Element == Self {
    collection.append(self)
  }

  /// Stores this cancellable token in the array.
  ///
  /// - Parameter array: The array in which to store this `CancellableToken`.
  @inlinable
  @inline(__always)
  func store(in array: inout [CancellableToken]) {
    array.append(self)
  }
}

public extension CancellableToken {

  /// Stores this cancellable token in the specified dictionary.
  ///
  /// - Parameter dictionary: The dictionary in which to store this `CancellableToken`.
  @inlinable
  @inline(__always)
  func store(in dictionary: inout [ObjectIdentifier: Self]) {
    dictionary[ObjectIdentifier(self)] = self
  }

  /// Removes this cancellable token from the specified dictionary.
  ///
  /// - Parameter dictionary: The dictionary in which to remove this `CancellableToken`.
  @inlinable
  @inline(__always)
  func remove(from dictionary: inout [ObjectIdentifier: Self]) {
    dictionary.removeValue(forKey: ObjectIdentifier(self))
  }

  /// Stores this cancellable token in the specified `OrderedDictionary`.
  ///
  /// - Parameter dictionary: The dictionary in which to store this `CancellableToken`.
  @inlinable
  @inline(__always)
  func store(in dictionary: inout OrderedDictionary<ObjectIdentifier, Self>) {
    dictionary[ObjectIdentifier(self)] = self
  }

  /// Removes this cancellable token from the specified `OrderedDictionary`.
  ///
  /// - Parameter dictionary: The dictionary in which to remove this `CancellableToken`.
  @inlinable
  @inline(__always)
  func remove(from dictionary: inout OrderedDictionary<ObjectIdentifier, Self>) {
    dictionary.removeValue(forKey: ObjectIdentifier(self))
  }
}

public extension CancellableToken where Self: Hashable {

  /// Stores this cancellable instance in the specified set.
  ///
  /// - Parameter set: The set in which to store this `CancellableToken`.
  @inlinable
  @inline(__always)
  func store(in set: inout Set<Self>) {
    set.insert(self)
  }
}

// MARK: - DispatchWorkItem + CancellableToken

extension DispatchWorkItem: CancellableToken {}

// MARK: - SimpleCancellableToken

/// A `CancellableToken` implementation with a cancel block.
public final class SimpleCancellableToken: CancellableToken, CustomStringConvertible {

  private let cancelOnDeallocate: Bool
  private let cancelBlock: (SimpleCancellableToken) -> Void
  private var isCancelled: Bool = false

  /// Initializes a `SimpleCancellableToken`.
  /// - Parameters:
  ///   - cancelOnDeallocate: Whether to call the cancel block on deallocate (`deinit`). Default is `true`.
  ///   - cancel: The cancel block to be called when the token cancels. Passes in the token itself.
  public init(cancelOnDeallocate: Bool = true, cancel: @escaping (SimpleCancellableToken) -> Void) {
    self.cancelOnDeallocate = cancelOnDeallocate
    self.cancelBlock = cancel
  }

  deinit {
    if cancelOnDeallocate {
      cancel()
    }
  }

  /// Cancels the token.
  ///
  /// If the token is already cancelled, this method does nothing.
  ///
  /// This method is not thread-safe. The cancel block is called on the same thread as the cancel method is called.
  public func cancel() {
    guard !isCancelled else {
      return
    }
    isCancelled = true
    cancelBlock(self)
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    "SimpleCancellableToken(\(rawPointer(self)))"
  }
}

// MARK: - ValueCancellableToken

/// A `CancellableToken` implementation that can hold a value.
public final class ValueCancellableToken<T>: CancellableToken, CustomStringConvertible {

  /// The value the token holds.
  public let value: T

  private let cancelOnDeallocate: Bool
  private let cancelBlock: (ValueCancellableToken<T>) -> Void
  private var isCancelled: Bool = false

  /// Initializes a `ValueCancellableToken`.
  ///
  /// - Parameters:
  ///   - value: The value the token holds.
  ///   - cancelOnDeallocate: Whether to call the cancel block on deallocate (`deinit`). Default is `true`.
  ///   - cancel: The cancel block to be called when the token cancels. Passes in the token itself.
  public init(value: T, cancelOnDeallocate: Bool = true, cancel: @escaping (ValueCancellableToken<T>) -> Void) {
    self.value = value
    self.cancelOnDeallocate = cancelOnDeallocate
    self.cancelBlock = cancel
  }

  deinit {
    if cancelOnDeallocate {
      cancel()
    }
  }

  /// Cancels the token.
  ///
  /// If the token is already cancelled, this method does nothing.
  ///
  /// This method is not thread-safe. The cancel block is called on the same thread as the cancel method is called.
  public func cancel() {
    guard !isCancelled else {
      return
    }
    isCancelled = true
    cancelBlock(self)
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    "ValueCancellableToken<\(T.self)>(\(rawPointer(self)))"
  }
}

// MARK: - CancellableTokenGroup

/// A token that can group other tokens together.
///
/// Cancelling the token group will cancel all underlying tokens.
public final class CancellableTokenGroup: CancellableToken, CustomStringConvertible {

  private let tokens: [CancellableToken]
  private let cancelOnDeallocate: Bool
  private let cancelBlock: (CancellableTokenGroup) -> Void
  private var isCancelled: Bool = false

  /// Initializes a `CancellableTokenGroup`.
  /// - Parameters:
  ///   - tokens: The child tokens.
  ///   - cancelOnDeallocate: Whether to call the cancel block on deallocate (`deinit`). Default is `true`.
  ///   - cancel: The cancel block to be called when the token cancels. Passes in the token itself.
  public init(tokens: [CancellableToken], cancelOnDeallocate: Bool = true, cancel: @escaping (CancellableTokenGroup) -> Void) {
    self.tokens = tokens
    self.cancelOnDeallocate = cancelOnDeallocate
    self.cancelBlock = cancel
  }

  deinit {
    if cancelOnDeallocate {
      cancel()
    }
  }

  /// Cancels the token.
  ///
  /// If the token is already cancelled, this method does nothing.
  ///
  /// This method is not thread-safe. The cancel block is called on the same thread as the cancel method is called.
  public func cancel() {
    guard !isCancelled else {
      return
    }
    isCancelled = true
    tokens.forEach { $0.cancel() }
    cancelBlock(self)
  }

  // MARK: - CustomStringConvertible

  public var description: String {
    "CancellableTokenGroup(\(rawPointer(self)))"
  }
}
