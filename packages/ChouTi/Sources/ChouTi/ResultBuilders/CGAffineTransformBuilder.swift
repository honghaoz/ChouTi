//
//  CGAffineTransformBuilder.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/31/21.
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

import CoreGraphics

public typealias CGAffineTransformBuilder = ArrayBuilder<CGAffineTransform>

// Original code kept for reference:
/*
 // #if swift(>=5.4)
 @resultBuilder
 public enum CGAffineTransformBuilder {}
 // #else
 // @_functionBuilder
 // public enum CGAffineTransformBuilder {}
 // #endif

 public extension CGAffineTransformBuilder {

   static func buildBlock(_ values: CGAffineTransformConvertible...) -> CGAffineTransformConvertible {
     buildArray(values)
   }

   /// For if/else/switch statements
   static func buildEither(first: CGAffineTransformConvertible) -> CGAffineTransformConvertible {
     first
   }

   /// For if/else/switch statements
   static func buildEither(second: CGAffineTransformConvertible) -> CGAffineTransformConvertible {
     second
   }

   /// For `if` only (without `else`) statements
   static func buildOptional(_ valueOrNil: CGAffineTransformConvertible?) -> CGAffineTransformConvertible {
     valueOrNil ?? CGAffineTransform.identity
   }

   /// For `for` loop
   static func buildArray(_ values: [CGAffineTransformConvertible]) -> CGAffineTransformConvertible {
     values
       .map { $0.asCGAffineTransform() }
       .reduce(into: CGAffineTransform.identity) { result, next in
         result = result.concatenating(next)
       }
   }

   // static func buildLimitedAvailability(_ component: CGAffineTransformConvertible) -> CGAffineTransformConvertible {
   //   component
   // }

   // MARK: - Other Expressions

   static func buildExpression(_ expression: CGAffineTransformConvertible) -> CGAffineTransformConvertible {
     expression
   }

   static func buildExpression(_ expression: Void) -> CGAffineTransformConvertible {
     CGAffineTransform.identity
   }

   // /// For final `return`.
   // public static func buildFinalResult(_ component: CGAffineTransformConvertible) -> <#Result#> {
   // }
 }

 public protocol CGAffineTransformConvertible {

   func asCGAffineTransform() -> CGAffineTransform
 }

 extension CGAffineTransform: CGAffineTransformConvertible {

   @inlinable
   public func asCGAffineTransform() -> CGAffineTransform {
     self
   }
 }

 */
