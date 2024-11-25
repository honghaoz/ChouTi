//
//  AnyBinding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/2/23.
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

import Combine
import Foundation

/// A concrete type-erased `BindingType`.
public final class AnyBinding<T>: BindingType {

  /// The wrapped binding.
  public let wrapped: any BindingType<T>

  private let wrappedAsHashable: AnyHashable

  /// Creates a type-erased binding that wraps the given binding.
  ///
  /// - Parameter binding: The binding to wrap.
  public init(_ binding: some BindingType<T>) {
    if let anyBinding = binding as? AnyBinding<T> { // avoid redundant wrapping
      self.wrapped = anyBinding.wrapped
      self.wrappedAsHashable = anyBinding.wrappedAsHashable
    } else {
      self.wrapped = binding
      self.wrappedAsHashable = binding
    }
  }

  // MARK: - BindingType

  public var value: T {
    wrapped.value
  }

  public var publisher: AnyPublisher<T, Never> {
    wrapped.publisher
  }

  public func observe(_ block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    wrapped.observe(block)
  }

  public func observe(_ block: @escaping (_ value: T) -> Void) -> BindingObservation {
    wrapped.observe(block)
  }

  // MARK: - Hashable

  public func hash(into hasher: inout Hasher) {
    wrappedAsHashable.hash(into: &hasher)
  }

  // MARK: - Equatable

  public static func == (lhs: AnyBinding, rhs: AnyBinding) -> Bool {
    lhs.wrappedAsHashable == rhs.wrappedAsHashable
  }
}

public extension BindingType {

  /// Returns a type-erased binding that wraps the given binding.
  ///
  /// - Returns: A type-erased binding.
  func eraseToAnyBinding() -> AnyBinding<Value> {
    if let anyBinding = self as? AnyBinding<Value> {
      return anyBinding
    } else {
      return AnyBinding(self)
    }
  }
}
