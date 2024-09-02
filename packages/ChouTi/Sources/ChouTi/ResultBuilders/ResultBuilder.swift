//
//  ResultBuilder.swift
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

/// A @resultBuilder convenient protocol.
public protocol ResultBuilder {

  associatedtype Input
  associatedtype Result

  static func buildFinalResult(_ item: ResultBuilderItem<Input>) -> Result
}

public indirect enum ResultBuilderItem<Expression> {
  case array([ResultBuilderItem])
  // case either(Either<ResultBuilderItem, ResultBuilderItem>)
  case optional(ResultBuilderItem?)
  case expressionSingle(Expression)
  case expressionArray([Expression])
  case void
}

public extension ResultBuilder {

  /// For a list of statements.
  static func buildBlock(_ items: ResultBuilderItem<Input>...) -> ResultBuilderItem<Input> {
    .array(items)
  }

  /// For `if`/`else`/`switch` statements.
  static func buildEither(first: ResultBuilderItem<Input>) -> ResultBuilderItem<Input> {
    first
  }

  /// For `if`/`else`/`switch` statements.
  static func buildEither(second: ResultBuilderItem<Input>) -> ResultBuilderItem<Input> {
    second
  }

  /// For `if` only (without `else`) statements.
  static func buildOptional(_ item: ResultBuilderItem<Input>?) -> ResultBuilderItem<Input> {
    .optional(item)
  }

  /// For `for` loop.
  static func buildArray(_ items: [ResultBuilderItem<Input>]) -> ResultBuilderItem<Input> {
    .array(items)
  }

  /// For `#available` statements.
  static func buildLimitedAvailability(_ item: ResultBuilderItem<Input>) -> ResultBuilderItem<Input> {
    item
  }

  /// For a single expression.
  static func buildExpression(_ expression: Input) -> ResultBuilderItem<Input> {
    .expressionSingle(expression)
  }

  /// For an array of expressions.
  static func buildExpression(_ expression: [Input]) -> ResultBuilderItem<Input> {
    .expressionArray(expression)
  }

  /// For a void expression.
  static func buildExpression(_ expression: Void) -> ResultBuilderItem<Input> {
    .void
  }
}

// See more: https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md#simple-result-builder-protocol
