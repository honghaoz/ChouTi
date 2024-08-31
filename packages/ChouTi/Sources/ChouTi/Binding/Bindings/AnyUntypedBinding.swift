//
//  AnyUntypedBinding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 12/31/23.
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

/// A concrete type-erased `BindingType`. Non generic version.
public final class AnyUntypedBinding: BindingType {

  private let baseAsHashable: AnyHashable

  private let _getValue: () -> Any
  private let _getPublisher: () -> AnyPublisher<Any, Never>
  private let _observeWithValueAndCancel: (@escaping (Any, @escaping BlockVoid) -> Void) -> BindingObservation
  private let _observeWithValue: (@escaping (Any) -> Void) -> BindingObservation

  /// Creates a type-erased binding that wraps the given binding.
  ///
  /// - Parameter binding: The binding to wrap.
  public init(_ binding: some BindingType<some Any>) {
    if let anyBinding = binding as? AnyUntypedBinding { // avoid redundant wrapping
      self.baseAsHashable = anyBinding.baseAsHashable
    } else {
      self.baseAsHashable = binding
    }

    _getValue = { binding.value as Any }
    _getPublisher = { binding.publisher.map { $0 as Any }.eraseToAnyPublisher() }
    _observeWithValueAndCancel = { block in
      binding.observe { value, cancel in
        block(value, cancel)
      }
    }
    _observeWithValue = { block in
      binding.observe { value in
        block(value)
      }
    }
  }

  // MARK: - BindingType

  public var value: Any {
    _getValue()
  }

  public var publisher: AnyPublisher<Any, Never> {
    _getPublisher()
  }

  public func observe(_ block: @escaping (_ value: Any, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    _observeWithValueAndCancel(block)
  }

  public func observe(_ block: @escaping (_ value: Any) -> Void) -> BindingObservation {
    _observeWithValue(block)
  }

  // MARK: - Hashable

  public func hash(into hasher: inout Hasher) {
    baseAsHashable.hash(into: &hasher)
  }

  // MARK: - Equatable

  public static func == (lhs: AnyUntypedBinding, rhs: AnyUntypedBinding) -> Bool {
    lhs.baseAsHashable == rhs.baseAsHashable
  }
}

public extension BindingType {

  /// Returns a type-erased binding that wraps the given binding.
  ///
  /// - Returns: A type-erased binding.
  @inlinable
  @inline(__always)
  func eraseToAnyUntypedBinding() -> AnyUntypedBinding {
    AnyUntypedBinding(self)
  }
}
