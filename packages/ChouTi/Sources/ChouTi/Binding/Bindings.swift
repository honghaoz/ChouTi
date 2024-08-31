//
//  Bindings.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/15/22.
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

public enum Bindings {

  /// Combine two bindings into a new binding.
  ///
  /// - Parameters:
  ///   - binding1: The first binding.
  ///   - binding2: The second binding.
  /// - Returns: A new binding that emits a tuple of the two bindings' values.
  public static func combine<A, B>(_ binding1: some BindingType<A>, _ binding2: some BindingType<B>) -> some BindingType<(A, B)> {
    binding1.combine(with: binding2)
  }

  /// Combine three bindings into a new binding.
  ///
  /// - Parameters:
  ///   - binding1: The first binding.
  ///   - binding2: The second binding.
  ///   - binding3: The third binding.
  /// - Returns: A new binding that emits a tuple of the three bindings' values.
  public static func combine<A, B, C>(_ binding1: some BindingType<A>, _ binding2: some BindingType<B>, _ binding3: some BindingType<C>) -> some BindingType<(A, B, C)> {
    binding1
      .combine(with: binding2)
      .combine(with: binding3)
      .map { value in
        (value.0.0, value.0.1, value.1)
      }
  }

  /// Combine four bindings into a new binding.
  ///
  /// - Parameters:
  ///   - binding1: The first binding.
  ///   - binding2: The second binding.
  ///   - binding3: The third binding.
  ///   - binding4: The fourth binding.
  /// - Returns: A new binding that emits a tuple of the four bindings' values.
  public static func combine<A, B, C, D>(_ binding1: some BindingType<A>, _ binding2: some BindingType<B>, _ binding3: some BindingType<C>, _ binding4: some BindingType<D>) -> some BindingType<(A, B, C, D)> {
    binding1
      .combine(with: binding2)
      .combine(with: binding3)
      .combine(with: binding4)
      .map { value in
        (value.0.0.0, value.0.0.1, value.0.1, value.1)
      }
  }

  /// Combine five bindings into a new binding.
  ///
  /// - Parameters:
  ///   - binding1: The first binding.
  ///   - binding2: The second binding.
  ///   - binding3: The third binding.
  ///   - binding4: The fourth binding.
  ///   - binding5: The fifth binding.
  /// - Returns: A new binding that emits a tuple of the five bindings' values.
  public static func combine<A, B, C, D, E>(_ binding1: some BindingType<A>, _ binding2: some BindingType<B>, _ binding3: some BindingType<C>, _ binding4: some BindingType<D>, _ binding5: some BindingType<E>) -> some BindingType<(A, B, C, D, E)> {
    binding1
      .combine(with: binding2)
      .combine(with: binding3)
      .combine(with: binding4)
      .combine(with: binding5)
      .map { value in
        (value.0.0.0.0, value.0.0.0.1, value.0.0.1, value.0.1, value.1)
      }
  }
}
