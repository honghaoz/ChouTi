//
//  LogMessage.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public struct LogMessage: ExpressibleByStringInterpolation, ExpressibleByStringLiteral {

  /// A type that represents a string literal.
  ///
  /// Valid types for `StringLiteralType` are `String` and `StaticString`.
  public typealias StringLiteralType = String

  /// The type each segment of a string literal containing interpolations
  /// should be appended to.
  ///
  /// The `StringLiteralType` of an interpolation type must match the
  /// `StringLiteralType` of the conforming type.
  public typealias StringInterpolation = LogMessageInterpolation

  // Seems like not needed

  // /// A type that represents an extended grapheme cluster literal.
  // ///
  // /// Valid types for `ExtendedGraphemeClusterLiteralType` are `Character`,
  // /// `String`, and `StaticString`.
  // public typealias ExtendedGraphemeClusterLiteralType = String

  // /// A type that represents a Unicode scalar literal.
  // ///
  // /// Valid types for `UnicodeScalarLiteralType` are `Unicode.Scalar`,
  // /// `Character`, `String`, and `StaticString`.
  // public typealias UnicodeScalarLiteralType = String

  @usableFromInline
  enum `Type` {

    case interpolation(LogMessageInterpolation)
    case literal(String)

    func makeString() -> String {
      switch self {
      case .interpolation(let interpolation):
        return interpolation._storage
      case .literal(let string):
        return string
      }
    }
  }

  @usableFromInline
  let type: `Type`

  private var materializedStringBox: Box<String?> = Box(value: nil)

  // MARK: - Init

  /// Creates an instance from a string interpolation.
  ///
  /// Most `StringInterpolation` types will store information about the
  /// literals and interpolations appended to them in one or more properties.
  /// `init(stringInterpolation:)` should use these properties to initialize
  /// the instance.
  ///
  /// - Parameter stringInterpolation: An instance of `StringInterpolation`
  ///             which has had each segment of the string literal appended
  ///             to it.LogStringInterpolation  @inlinable public init(stringInterpolation: LogInterpolation) {
  @inlinable
  public init(stringInterpolation: LogMessageInterpolation) {
    self.type = .interpolation(stringInterpolation)
  }

  /// Creates an instance initialized to the given string value.
  ///
  /// - Parameter value: The value of the new instance.
  @inlinable
  public init(stringLiteral value: String = "") {
    self.type = .literal(value)
  }

  /// Creates an instance initialized to the given string value.
  ///
  /// - Parameter value: The value of the new instance.
  @inlinable
  public init(_ value: String) {
    self.type = .literal(value)
  }

  @usableFromInline
  func materializedString() -> String {
    if let materializedString = materializedStringBox.value {
      return materializedString
    } else {
      let newString = type.makeString()
      materializedStringBox.value = newString
      return newString
    }
  }
}

public extension LogMessage {

  enum PrivacyLevel {
    case `public`
    case `private`
  }
}

// MARK: - LogMessageInterpolation

// This is the string builder
//
// Doc: https://developer.apple.com/documentation/swift/stringinterpolationprotocol
public struct LogMessageInterpolation: StringInterpolationProtocol {

  public typealias StringLiteralType = String

  /// Creates an empty instance ready to be filled with string literal content.
  ///
  /// Don't call this initializer directly. Instead, initialize a variable or
  /// constant using a string literal with interpolated expressions.
  ///
  /// Swift passes this initializer a pair of arguments specifying the size of
  /// the literal segments and the number of interpolated segments. Use this
  /// information to estimate the amount of storage you will need.
  ///
  /// - Parameter literalCapacity: The approximate size of all literal segments
  ///   combined. This is meant to be passed to `String.reserveCapacity(_:)`;
  ///   it may be slightly larger or smaller than the sum of the counts of each
  ///   literal segment.
  /// - Parameter interpolationCount: The number of interpolations which will be
  ///   appended. Use this value to estimate how much additional capacity will
  ///   be needed for the interpolated segments.
  public init(literalCapacity: Int, interpolationCount: Int) {
    let capacityPerInterpolation = 8 // just an estimation of each interpolation size
    let initialCapacity = literalCapacity + interpolationCount * capacityPerInterpolation
    _storage.reserveCapacity(initialCapacity)
  }

  /// Appends a literal segment to the interpolation.
  ///
  /// Don't call this method directly. Instead, initialize a variable or
  /// constant using a string literal with interpolated expressions.
  ///
  /// Interpolated expressions don't pass through this method; instead, Swift
  /// selects an overload of `appendInterpolation`. For more information, see
  /// the top-level `StringInterpolationProtocol` documentation.
  ///
  /// - Parameter literal: A string literal containing the characters
  ///   that appear next in the string literal.
  @inlinable
  public mutating func appendLiteral(_ literal: String) {
    _storage += literal
  }

  //  @inlinable
  //  public mutating func appendInterpolation<T: TextOutputStreamable & CustomStringConvertible>(_ value: T) {
  //    value.write(to: &_storage)
  //  }
  //
  //  @inlinable
  //  public mutating func appendInterpolation<T: TextOutputStreamable>(_ value: T) {
  //    value.write(to: &_storage)
  //  }
  //
  //  @inlinable
  //  public mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T) {
  //    _storage += value.description
  //  }

  @inlinable
  public mutating func appendInterpolation(_ value: some Any) {
    _storage += String(describing: value)
  }

  @inlinable
  public mutating func appendInterpolation(_ value: some Any, privacy: LogMessage.PrivacyLevel) {
    switch privacy {
    case .public:
      _storage += String(describing: value)
    case .private:
      _storage += "<private>"
    }
  }

  /// Provides `Optional` string interpolation without forcing the use of `String(describing:)`.
  /// Example:
  /// ```swift
  /// let valueOrNil: String? = nil
  /// let string = "There's \(valueOrNil, default: "nil")"
  /// ```
  @inlinable
  public mutating func appendInterpolation(_ value: (some Any)?, default defaultValue: String) {
    if let value {
      appendInterpolation(value)
    } else {
      appendLiteral(defaultValue)
    }
  }

  @usableFromInline
  var _storage: String = "" // TODO: instead of construction string, make it lazy?
}

// Doc:
// - https://developer.apple.com/documentation/swift/expressiblebystringinterpolation#
// - https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md#fix-expressiblebystringinterpolation
// References:
// - https://gist.github.com/beccadax/0b46ce25b7da1049e61b4669352094b6
// - https://alisoftware.github.io/swift/2018/12/15/swift5-stringinterpolation-part1/
// - https://alisoftware.github.io/swift/2018/12/16/swift5-stringinterpolation-part2/
// - https://www.hackingwithswift.com/articles/163/how-to-use-custom-string-interpolation-in-swift
