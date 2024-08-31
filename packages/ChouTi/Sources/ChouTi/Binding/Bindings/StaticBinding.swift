//
//  StaticBinding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/7/23.
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

/// A binding that never changes its value.
public final class StaticBinding<T>: BindingType, InternalBindingType {

  // MARK: - InternalBindingType

  func _removeRegisteredObservation(_ observation: BindingObservation) {
    implementation.removeRegisteredObservation(observation)
  }

  // MARK: - BindingType

  /// The value of the binding.
  public let value: T

  /// A publisher that emits the current value of the binding.
  ///
  /// The publisher will emit the current value immediately when there's a subscriber.
  public var publisher: AnyPublisher<T, Never> {
    implementation.publisher
  }

  /// Observes the binding for value changes.
  ///
  /// - Parameter block: A closure that will be called when the binding's value changes. The closure provides a cancel handler to stop observing.
  /// - Returns: An observation as a token that can be used to stop observing.
  public func observe(_ block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    implementation.observe(binding: self, block: block)
  }

  /// Observes the binding for value changes.
  ///
  /// - Parameter block: A closure that will be called when the binding's value changes.
  /// - Returns: An observation as a token that can be used to stop observing.
  public func observe(_ block: @escaping (_ value: T) -> Void) -> BindingObservation {
    implementation.observe(binding: self, block: block)
  }

  // MARK: - Private

  private lazy var implementation = BindingImplementation<T>(binding: self)

  /// Initialize a static binding with a value.
  ///
  /// - Parameter value: The value to initialize the binding with.
  public init(_ value: T) {
    self.value = value
  }
}

public extension StaticBinding where T == Void {

  /// Initialize a static binding with no value.
  convenience init() {
    self.init(())
  }
}

// MARK: - Expressible

// Bool

extension StaticBinding: ExpressibleByBooleanLiteral where T == Bool {

  public typealias BooleanLiteralType = T

  public convenience init(booleanLiteral value: T) {
    self.init(value)
  }
}

// Numbers

extension StaticBinding: ExpressibleByIntegerLiteral where T == Int {

  public typealias IntegerLiteralType = T

  public convenience init(integerLiteral value: T) {
    self.init(value)
  }
}

extension StaticBinding: ExpressibleByFloatLiteral where T == Double {

  public typealias FloatLiteralType = T

  public convenience init(floatLiteral value: T) {
    self.init(value)
  }
}

// String

extension StaticBinding: ExpressibleByUnicodeScalarLiteral where T == String {

  public typealias UnicodeScalarLiteralType = String

  public convenience init(unicodeScalarLiteral value: T) {
    self.init(value)
  }
}

extension StaticBinding: ExpressibleByExtendedGraphemeClusterLiteral where T == String {

  public typealias ExtendedGraphemeClusterLiteralType = T

  public convenience init(extendedGraphemeClusterLiteral value: T) {
    self.init(value)
  }
}

extension StaticBinding: ExpressibleByStringLiteral where T == String {

  public typealias StringLiteralType = T

  public convenience init(stringLiteral value: T) {
    self.init(value)
  }
}
