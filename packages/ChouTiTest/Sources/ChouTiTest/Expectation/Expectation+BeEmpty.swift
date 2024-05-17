//
//  Expectation+BeEmpty.swift
//
//  Created by Honghao Zhang on 10/28/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the actual value is empty.
public struct BeEmptyExpectation<T: Collection>: Expectation {

  public typealias ThrownErrorType = Never

  public func evaluate(_ actualValue: T) -> Bool {
    actualValue.isEmpty
  }

  public var description: String {
    "be empty"
  }
}

/// Make an expectation that the actual value is empty.
/// - Returns: An expectation.
public func beEmpty<T>() -> BeEmptyExpectation<T> {
  BeEmptyExpectation()
}
