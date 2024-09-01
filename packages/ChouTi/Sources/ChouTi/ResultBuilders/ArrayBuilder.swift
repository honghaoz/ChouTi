//
//  ArrayBuilder.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/11/22.
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

/// A `ResultBuilder` for building array of elements.
@resultBuilder
public enum ArrayBuilder<T>: ResultBuilder {

  public static func buildFinalResult(_ item: ResultBuilderItem<T>) -> [T] {
    switch item {
    case .array(let items):
      return items.flatMap { buildFinalResult($0) }
    // case .either(.left(let item)):
    //   return buildFinalResult(item)
    // case .either(.right(let item)):
    //   return buildFinalResult(item)
    case .optional(let item?):
      return buildFinalResult(item)
    case .optional(nil):
      return []
    case .expressionSingle(let input):
      return [input]
    case .expressionArray(let inputArray):
      return inputArray
    case .void:
      return []
    }
  }
}

public extension Array {

  /// Initialize an array with an `ArrayBuilder`.
  init(@ArrayBuilder<Element> builder: () -> Self) {
    self = builder()
  }
}
