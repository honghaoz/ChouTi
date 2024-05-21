//
//  Either.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// A type that represents a value of one of two possible types.
public enum Either<A, B> {
  case left(A)
  case right(B)
}

extension Either: Equatable where A: Equatable, B: Equatable {}

extension Either: Hashable where A: Hashable, B: Hashable {}
