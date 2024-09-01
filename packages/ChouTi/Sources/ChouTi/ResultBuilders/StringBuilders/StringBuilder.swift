//
//  StringBuilder.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/8/22.
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

/// Build into `String` array.
public typealias StringArrayBuilder = ArrayBuilder<String>

/// Build into `String?` array.
public typealias OptionalStringArrayBuilder = ArrayBuilder<String?>

public extension String {

  /**
   Initialize a string with an `StringArrayBuilder`.

   Example:
   ```
   String {
     if Bool.random() {
       "Yes"
     } else {
       "No"
     }
   }
   ```

   - Parameters:
     - separator: The separator to join the strings. Default is `\n`.
     - builder: The builder block.
   */
  init(separator: String = "\n", @StringArrayBuilder builder: () -> [String]) {
    self = builder().joined(separator: separator)
  }

  /**
   Initialize an optional string with an `OptionalStringArrayBuilder`.

   Example:
   ```
   String {
     if Bool.random() {
       "Yes"
     }
   } as String?
   ```

   - Parameters:
     - separator: The separator to join the strings. Default is `\n`.
     - builder: The builder block.
   */
  init?(separator: String = "\n", @OptionalStringArrayBuilder builder: () -> [String?]) {
    let compacted = builder().compactMap { $0 }
    if compacted.isEmpty {
      return nil
    }

    self = compacted.joined(separator: separator)
  }
}
