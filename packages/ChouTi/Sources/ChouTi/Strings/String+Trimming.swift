//
//  String+Trimming.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/18/20.
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

// MARK: - Removing Characters

public extension StringProtocol {

  /// Removes specified characters from the string.
  ///
  /// Example:
  /// ```swift
  /// let original = "Hello$%^& World!!123"
  /// let result = original.removingCharacters(in: "$%^&!123")
  /// print(result) // prints: "Hello World"
  /// ```
  ///
  /// - Parameter characters: A string containing the characters to be removed.
  /// - Returns: A new string with all occurrences of the specified characters removed.
  /// - Complexity: O(n), where n is the length of the string.
  func removingCharacters(in characters: String) -> String {
    var result = ""
    result.reserveCapacity(self.count)

    let characterSet = Set(characters.unicodeScalars)
    for scalar in self.unicodeScalars where !characterSet.contains(scalar) {
      result.unicodeScalars.append(scalar)
    }

    return result
  }

  /// Removes specified characters.
  ///
  /// Example:
  /// ```swift
  /// let original = "Hello👋 World🌍"
  /// let result = original.removingCharacters(in: .symbols)
  /// print(result) // prints: "Hello World"
  /// ```
  ///
  /// - Parameter characterSet: A character set containing the characters to be removed.
  /// - Returns: A new string with all occurrences of the specified characters removed.
  /// - Complexity: O(n), where n is the length of the string.
  func removingCharacters(in characterSet: CharacterSet) -> String {
    var result = ""
    result.reserveCapacity(self.count)

    for scalar in self.unicodeScalars where !characterSet.contains(scalar) {
      result.unicodeScalars.append(scalar)
    }

    return result
  }
}

// MARK: - Trimming Characters

public extension StringProtocol {

  /// Returns a subsequence made by removing instances of a specified leading character.
  ///
  /// Example usage:
  /// ```swift
  /// let originalString = "aaaThink different."
  /// let trimmedString = originalString.trimmingLeadingCharacter("a")
  /// print(trimmedString) // prints: "Think different."
  /// ```
  ///
  /// - Parameter character: The leading character to be removed from the string.
  /// - Returns: A subsequence with all leading instances of the specified character removed.
  @inlinable
  @inline(__always)
  func trimmingLeadingCharacter(_ character: Character) -> Self.SubSequence {
    trimmingLeadingCharacters(in: CharacterSet(charactersIn: String(character)))
  }

  /// Returns a subsequence made by removing leading characters from a specified string.
  ///
  /// Example usage:
  /// ```swift
  /// let originalString = " \n Think different."
  /// let trimmedString = originalString.trimmingLeadingCharacters(in: " \n")
  /// print(trimmedString) // prints: "Think different."
  /// ```
  ///
  /// - Parameter characters: The set of characters to be removed from the leading part of the string.
  /// - Returns: A subsequence with all leading instances of the specified characters removed.
  @inlinable
  @inline(__always)
  func trimmingLeadingCharacters(in characters: String) -> Self.SubSequence {
    trimmingLeadingCharacters(in: CharacterSet(charactersIn: characters))
  }

  /// Returns a subsequence made by removing leading characters from a specified set.
  ///
  /// Example usage:
  /// ```swift
  /// let originalString = "aaabacdef"
  /// let trimmedString = originalString.trimmingLeadingCharacters(in: CharacterSet(charactersIn: "ab"))
  /// print(trimmedString) // prints: "cdef"
  /// ```
  ///
  /// - Parameter characters: The set of characters to be removed from the leading part of the string.
  /// - Returns: A subsequence with all leading instances of the specified characters removed.
  func trimmingLeadingCharacters(in characters: CharacterSet) -> Self.SubSequence {
    guard !isEmpty else {
      return self[startIndex ..< startIndex]
    }
    guard let index = firstIndex(where: { !$0.unicodeScalars.contains(where: characters.contains) }) else {
      return self[endIndex ..< endIndex]
    }
    return self[index...]
  }

  /// Returns a subsequence made by removing instances of a specified trailing character.
  ///
  /// Example usage:
  /// ```swift
  /// let originalString = "Think different.\n\n"
  /// let trimmedString = originalString.trimmingTrailingCharacter("\n")
  /// print(trimmedString) // Prints: "Think different."
  /// ```
  ///
  /// - Parameter character: The trailing character to be removed from the string.
  /// - Returns: A subsequence with all trailing instances of the specified character removed.
  @inlinable
  @inline(__always)
  func trimmingTrailingCharacter(_ character: Character) -> Self.SubSequence {
    trimmingTrailingCharacters(in: CharacterSet(charactersIn: String(character)))
  }

  /// Returns a subsequence made by removing trailing characters from a specified string.
  ///
  /// Example usage:
  /// ```swift
  /// let originalString = "Think different.\n \n "
  /// let trimmedString = originalString.trimmingTrailingCharacters(in: " \n")
  /// print(trimmedString) // prints: "Think different."
  /// ```
  ///
  /// - Parameter characters: The set of characters to be removed from the trailing part of the string.
  /// - Returns: A subsequence with all trailing instances of the specified characters removed.
  @inlinable
  @inline(__always)
  func trimmingTrailingCharacters(in characters: String) -> Self.SubSequence {
    trimmingTrailingCharacters(in: CharacterSet(charactersIn: characters))
  }

  /// Returns a subsequence made by removing trailing characters from a specified set.
  ///
  /// Example usage:
  /// ```swift
  /// let originalString = "Think different.\n \n "
  /// let trimmedString = originalString.trimmingTrailingCharacters(in: " \n")
  /// print(trimmedString) // prints: "Think different."
  /// ```
  ///
  /// - Parameter characters: The set of characters to be removed from the trailing part of the string.
  /// - Returns: A subsequence with all trailing instances of the specified characters removed.
  func trimmingTrailingCharacters(in characters: CharacterSet) -> Self.SubSequence {
    guard !isEmpty else {
      return self[startIndex ..< startIndex]
    }
    guard let index = lastIndex(where: { !$0.unicodeScalars.contains(where: characters.contains) }) else {
      return self[startIndex ..< startIndex]
    }
    return self[startIndex ... index]
  }
}
