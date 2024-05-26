//
//  Expectation+ThrowErrorType.swift
//
//  Created by Honghao Zhang on 11/11/23.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// An expectation that the expression throws an error of the expected type.
public struct ThrowErrorTypeExpectation<E: Swift.Error>: Expectation {

  public typealias T = Any
  public typealias ThrownErrorType = E

  public func evaluate(_ actualValue: T) -> Bool {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
  }

  public func evaluateError(_ thrownError: ThrownErrorType) -> Bool {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
  }

  public var description: String {
    fatalError("unexpected call") // swiftlint:disable:this fatal_error
  }
}

/// Make an expectation that the expression throws an error of the expected type.
/// - Parameter error: The error type expect to throw.
/// - Returns: An expectation.
public func throwErrorOfType<E: Swift.Error>(_ error: E.Type) -> ThrowErrorTypeExpectation<E> {
  ThrowErrorTypeExpectation()
}
