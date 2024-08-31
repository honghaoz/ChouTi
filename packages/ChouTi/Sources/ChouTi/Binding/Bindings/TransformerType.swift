//
//  TransformerType.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/24/23.
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

/// A transformer type that maps the upstream binding's value to the transformed binding.
protocol TransformerType<S, T> {

  /// The upstream value type.
  associatedtype S

  /// The transformed value type.
  associatedtype T

  /// Get the initial value to set for the `TransformedBinding`.
  func initialValue(for upstreamValue: S) -> T

  /// When the upstream value changes, invokes this method.
  /// - Parameters:
  ///   - newUpstreamValue: The new upstream value.
  ///   - setTransformedValue: A block to set the transformed binding's value.
  func upstreamValueChanged(newUpstreamValue: S, setTransformedValue: @escaping (_ transformedValue: T) -> Void)
}

/// A simple & concrete transformer.
struct BindingTransformer<S, T>: TransformerType {

  private let getInitialValue: (_ upstreamValue: S) -> T
  private let upstreamValueChanged: (_ newUpstreamValue: S, _ setTransformedValue: @escaping (_ transformedValue: T) -> Void) -> Void

  init(getInitialValue: @escaping (_ upstreamValue: S) -> T,
       upstreamValueChanged: @escaping (_ newUpstreamValue: S, _ setTransformedValue: @escaping (_ transformedValue: T) -> Void) -> Void)
  {
    self.getInitialValue = getInitialValue
    self.upstreamValueChanged = upstreamValueChanged
  }

  func initialValue(for upstreamValue: S) -> T {
    getInitialValue(upstreamValue)
  }

  func upstreamValueChanged(newUpstreamValue: S, setTransformedValue: @escaping (_ transformedValue: T) -> Void) {
    upstreamValueChanged(newUpstreamValue, setTransformedValue)
  }
}
