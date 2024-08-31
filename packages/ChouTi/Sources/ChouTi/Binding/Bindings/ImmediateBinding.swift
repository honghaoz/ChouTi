//
//  ImmediateBinding.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/9/23.
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

/// A binding that emits value immediately when observes.
final class ImmediateBinding<T>: BindingType {

  // MARK: - BindingType

  var value: T { upstreamBinding.value }

  var publisher: AnyPublisher<T, Never> {
    upstreamBinding.publisher
  }

  func observe(_ block: @escaping (_ value: T, _ cancel: @escaping BlockVoid) -> Void) -> BindingObservation {
    block(value) {}
    return upstreamBinding.observe(block)
  }

  func observe(_ block: @escaping (_ value: T) -> Void) -> BindingObservation {
    block(value)
    return upstreamBinding.observe(block)
  }

  // MARK: - Private

  private let upstreamBinding: any BindingType<T>

  init(upstreamBinding: some BindingType<T>) {
    self.upstreamBinding = upstreamBinding
  }
}
